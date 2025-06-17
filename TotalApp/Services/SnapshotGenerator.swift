//
//  SnapshotsGenerator.swift
//  TotalApp
//
//  Created by Rafal Bereski on 10/04/2025.
//

import Foundation

public class SnapshotGenerator {
    private let currencyConverter: CurrencyConverterType
    private let configManager: ConfigManager
    private let priceDataProviders: PriceDataProvidersMap
    private typealias ValueInfo = (unitPrice: Double, totalPrice: Double, currency: Currency)
    
    public init(
        configManager: ConfigManager,
        currencyConverter: CurrencyConverterType,
        priceDataProviders: PriceDataProvidersMap
    ) {
        self.configManager = configManager
        self.currencyConverter = currencyConverter
        self.priceDataProviders = priceDataProviders
    }
    
    public func generate(ts: Timestamp, interval: Interval, assets: [Asset]) async throws(SnapshotError) -> Snapshot {
        let createdTs = ts
        let intervalTs = interval.startTimestamp(ts: ts)
        var configuredPriceProviders = Set<PriceDataProviderID>()
        
        let totalValueEntry = TotalValue(createdTs: createdTs, intervalTs: intervalTs)
        var categoryValueEntries : [AssetType : CategoryValue] = [:]
        var assetValueEntries: [AssetValue] = []
        
        for category in AssetType.allCases {
            categoryValueEntries[category] = CategoryValue(createdTs: createdTs, intervalTs: intervalTs, assetType: category)
        }
        
        guard let settings = try? await configManager.snapshotsConfig else {
            throw .unavailableSnapshotConfiguration
        }
        
        do {
            
            let supportedCurrencies = settings.supportedCurrencies
            let btcPriceProviderId = settings.btcPriceProvider
            
            currencyConverter.btcPriceProviderId = btcPriceProviderId
            try await currencyConverter.configure(with: configManager)
            try await currencyConverter.updateRates()
            
            for asset in assets {
                var values: [Double] = .init(repeating: 0, count: Consts.maxSupportedCurrencies)
                let (unitPrice, totalPrice, currency) = try await calculateValue(asset, configuredProviders: &configuredPriceProviders)
                
                for i in 0 ..< supportedCurrencies.count {
                    values[i] = try currencyConverter.convert(totalPrice, from: currency, to: supportedCurrencies[i])
                }
                
                assetValueEntries.append(
                    AssetValue(
                        createdTs: createdTs,
                        intervalTs: intervalTs,
                        assetId: asset.id,
                        assetType: asset.type,
                        unitPrice: unitPrice,
                        valueBtc: values[0],
                        valueUsd: values[1],
                        valueCurr1: values[2],
                        valueCurr2: values[3],
                        valueCurr3: values[4]
                    )
                )
                
                for i in 0 ..< Consts.maxSupportedCurrencies {
                    categoryValueEntries[asset.type]?.add(value: values[i], currIdx: i)
                    totalValueEntry.add(value: values[i], currIdx: i)
                }
            }
            
            let snapshot = Snapshot(
                assetValues: assetValueEntries,
                categoryValues: Array(categoryValueEntries.values),
                totalValue: totalValueEntry
            )
        
            return snapshot
        } catch {
            switch error {
                case let error as CurrencyConverterError: throw .currencyConversionError(error)
                case let error as DataProviderError: throw .priceDataProviderError(error)
                default: throw (error as? SnapshotError) ?? .unknownError(error)
            }
        }
    }
    
    private func calculateValue( _ asset: Asset, configuredProviders: inout Set<PriceDataProviderID>) async throws(SnapshotError) -> ValueInfo {
        switch asset.type {
            case .cash:
                return ValueInfo(unitPrice: 1, totalPrice: asset.amount, currency: asset.currency)
            default:
                return try await calculateAssetValue(asset, configuredProviders: &configuredProviders)
        }
    }
    
    private func calculateAssetValue(_ asset: Asset,  configuredProviders: inout Set<PriceDataProviderID>) async throws(SnapshotError) -> ValueInfo {
        guard let providerId: PriceDataProviderID = try? .parse(asset.priceProviderId) else {
            throw .unknownPriceDataProvider(assetName: asset.name)
        }
        
        if (providerId == .fixedPrice) {
            return ValueInfo(unitPrice: asset.fixedPrice, totalPrice: asset.fixedPrice * asset.amount,  currency: asset.currency)
        }
        
        guard let symbol = asset.priceProviderSymbol, !symbol.isEmpty else { throw .missingSymbol(assetName: asset.name) }
        guard let provider = priceDataProviders[providerId] else { throw .unavailablePriceDataProvider(assetName: asset.name) }
        
        do {
            if !configuredProviders.contains(providerId) {
                try await provider.configure(with: configManager)
                configuredProviders.insert(providerId)
            }
            let price = try await provider.fetchPrice(symbol: symbol)
            return ValueInfo(unitPrice: price.price,  totalPrice: price.price * asset.amount, currency: asset.currency)
        } catch let e {
            throw .priceDataProviderError(e)
        }
    }
}
