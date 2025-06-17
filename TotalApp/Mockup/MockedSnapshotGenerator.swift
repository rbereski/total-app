//
//  MockedSnapshotGenerator.swift
//  TotalApp
//
//  Created by Rafal Bereski on 06/05/2025.
//

import Foundation

public class MockedSnapshotGenerator {
    private let currencyConverter: CurrencyConverterType
    private let priceDataProviders: PriceDataProvidersMap
    private typealias ValueInfo = (unitPrice: Double, totalPrice: Double, currency: Currency)
    
    public init(
        currencyConverter: CurrencyConverterType,
        priceDataProviders: PriceDataProvidersMap
    ) {
        self.currencyConverter = currencyConverter
        self.priceDataProviders = priceDataProviders
    }
    
    public func generate(ts: Timestamp, interval: Interval, assets: [Asset], config: SnapshotsConfig) throws -> Snapshot {
        let createdTs = ts
        let intervalTs = interval.startTimestamp(ts: ts)
        
        let totalValueEntry = TotalValue(createdTs: createdTs, intervalTs: intervalTs)
        var categoryValueEntries : [AssetType : CategoryValue] = [:]
        var assetValueEntries: [AssetValue] = []
        
        for category in AssetType.allCases {
            categoryValueEntries[category] = CategoryValue(
                createdTs: createdTs,
                intervalTs: intervalTs,
                assetType: category
            )
        }
        
        let supportedCurrencies = config.supportedCurrencies
        
        for asset in assets {
            var values: [Double] = .init(repeating: 0, count: Consts.maxSupportedCurrencies)
            let (unitPrice, totalPrice, currency) = try calculateValue(asset)
            
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
    }
    
    private func calculateValue(_ asset: Asset) throws -> ValueInfo {
        switch asset.type {
            case .cash: return calculateCashValue(asset)
            default: return try calculateAssetValue(asset)
        }
    }
    
    private func calculateAssetValue(_ asset: Asset) throws -> ValueInfo {
        guard
            let symbol = asset.priceProviderSymbol,
            let providerId: PriceDataProviderID = try? .parse(asset.priceProviderId),
            let provider = priceDataProviders[providerId] as? MockedPriceDataProviderType
            else { fatalError("unkown price data provider") }
        let price = provider.fetchPriceSync(symbol: symbol)
        return (price.price, price.price * asset.amount, asset.currency)
    }
    
    private func calculateCashValue(_ asset: Asset) -> ValueInfo {
        return (1, asset.amount, asset.currency)
    }
}
