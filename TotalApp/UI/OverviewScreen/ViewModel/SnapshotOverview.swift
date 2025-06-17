//
//  SnapshotOverview.swift
//  TotalApp
//
//  Created by Rafal Bereski on 26/05/2025.
//

import Observation

@MainActor
@Observable
public class SnapshotOverview {
    public struct CategorySummary: Identifiable, Sendable {
        public var id: AssetType
        public var name: String
        public var value: [Currency: Double]
        public var percentage: Double
    }
    
    public struct SymbolSummary: Identifiable, Sendable {
        public var id: String
        public var name: String
        public var value: [Currency: Double]
        public var percentage: Double
        public var colorIndex: Int = 0
    }
    
    @ObservationIgnored private let assetsManager: AssetsManager
    @ObservationIgnored private let supportedCurrencies: [Currency]
    
    public var formattedPortolioValues: [Currency: String] = [:]
    public var assetTypesAllocation: [CategorySummary] = []
    public var cashAllocation: [SymbolSummary] = []
    public var cryptoAllocation: [SymbolSummary] = []
    public var stocksAllocation: [SymbolSummary] = []
    
    public var hasCurrenciesSummary: Bool { !cashAllocation.isEmpty }
    public var hasCategoriesSummary: Bool { !assetTypesAllocation.isEmpty }
    public var hasCryptoSummary: Bool { !cryptoAllocation.isEmpty }
    public var hasStocksSummary: Bool { !stocksAllocation.isEmpty }
    
    public init(assetsManager: AssetsManager, supportedCurrencies: [Currency]) {
        self.assetsManager = assetsManager
        self.supportedCurrencies = supportedCurrencies
    }
    
    public nonisolated func update(snapshot: Snapshot) async {
        let formattedPortfolioValues = await createFormattedPortolioValues(snapshot: snapshot)
        let assetTypesAllocation = await createCategorySummaries(snapshot)
        let cashSummary = await createCurrencySummaries(snapshot)
        let cryptoAllocation = await createSymbolsSummaries(snapshot, category: .crypto)
        let stocksAllocation = await createSymbolsSummaries(snapshot, category: .stock)
        await MainActor.run {
            self.formattedPortolioValues = formattedPortfolioValues
            self.assetTypesAllocation = assetTypesAllocation
            self.cashAllocation = cashSummary
            self.cryptoAllocation = cryptoAllocation
            self.stocksAllocation = stocksAllocation
        }
    }
    
    private nonisolated func createFormattedPortolioValues(snapshot: Snapshot) async -> [Currency: String] {
        var formattedValues: [Currency: String] = [:]
        for (idx, currency) in supportedCurrencies.enumerated() {
            formattedValues[currency] = currency.isFiat
                ? "\(NumberFormattersCache.shared.formatAsInteger(decimal: snapshot.totalValue.values[idx])) \(currency.symbol)"
                : NumberFormattersCache.shared.format(price: snapshot.totalValue.values[idx], currency: currency)
        }
        return formattedValues
    }
    
    private nonisolated func createCategorySummaries(_ snapshot: Snapshot) async -> [CategorySummary] {
        let totalUsd = snapshot.categoryValues.map(\.valueUsd).reduce(0, +)
        
        let categorySummaries: [CategorySummary] = snapshot.categoryValues
            .filter { $0.valueUsd > 0 }
            .map { ctg in
                let keysWithValues = (0..<supportedCurrencies.count).map {
                    (supportedCurrencies[$0], ctg.values[$0])
                }
                return CategorySummary(
                    id: ctg.assetType,
                    name: ctg.assetType.legendLabel,
                    value: Dictionary(uniqueKeysWithValues: keysWithValues),
                    percentage: ctg.valueUsd / totalUsd
                )
            }
            .sorted(by: { $0.id.sortOrder < $1.id.sortOrder })
        
        return categorySummaries
    }
    
    private nonisolated func createCurrencySummaries(_ snapshot: Snapshot) async  -> [SymbolSummary] {
        var totalUsd: Double = 0
        var currencyValues: [Currency: [Currency: Double]] = [:]
        let defaultValue = Dictionary(uniqueKeysWithValues: supportedCurrencies.map { ($0, 0.0) })
        for assetValue in snapshot.assetValues {
            if let asset = await assetsManager.getAsset(id: assetValue.assetId), asset.type == .cash {
                totalUsd += assetValue.valueUsd
                for (i, currency) in supportedCurrencies.enumerated() {
                    currencyValues[asset.currency, default: defaultValue][currency, default: 0] += assetValue.values[i]
                }
            }
        }
        
        return currencyValues.map { (key, values) in
            SymbolSummary(
                id: key.symbol,
                name: key.symbol,
                value: currencyValues[key]!,
                percentage: currencyValues[key]![.usd]! / totalUsd
            )
        }
        .reducedToTopItemsAndOther()
        .withAssignedColorIndexes()
    }
    
    private nonisolated func createSymbolsSummaries(_ snapshot: Snapshot, category: AssetType) async  -> [SymbolSummary] {
        var totalUsd: Double = 0
        var symbolValues: [String: [Currency: Double]] = [:]
        let defaultValue = Dictionary(uniqueKeysWithValues: supportedCurrencies.map { ($0, 0.0) })
        for assetValue in snapshot.assetValues {
            if let asset = await assetsManager.getAsset(id: assetValue.assetId), asset.type == category {
                totalUsd += assetValue.valueUsd
                let symbol = asset.priceProviderSymbol ?? "Unknown"
                for (i, currency) in supportedCurrencies.enumerated() {
                    symbolValues[symbol, default: defaultValue][currency, default: 0] += assetValue.values[i]
                }
            }
        }
        
        return symbolValues.map { (key, values) in
            SymbolSummary(
                id: key,
                name: key,
                value: symbolValues[key]!,
                percentage: symbolValues[key]![.usd]! / totalUsd
            )
        }
        .reducedToTopItemsAndOther()
        .withAssignedColorIndexes()
    }
}

private extension Array where Element == SnapshotOverview.SymbolSummary {
    func reducedToTopItemsAndOther(n: Int = 10, otherLabel: String = "Other") -> [SnapshotOverview.SymbolSummary] {
        let sorted = self.sorted { $0.percentage > $1.percentage }
        guard self.count > n else { return sorted }
        let topItems = sorted.prefix(n - 1)
        let remainingItems = sorted.dropFirst(n - 1)
        var combinedValue: [Currency: Double] = [:]
        var combinedPercentage: Double = 0
        for item in remainingItems {
            for (currency, amount) in item.value {
                combinedValue[currency, default: 0] += amount
            }
            combinedPercentage += item.percentage
        }
        let others = SnapshotOverview.SymbolSummary(id: otherLabel, name: otherLabel, value: combinedValue, percentage: combinedPercentage)
        return Array(topItems) + [others]
    }
    
    func withAssignedColorIndexes() -> [SnapshotOverview.SymbolSummary] {
        return self.enumerated().map { index, item in
            var updatedItem = item
            updatedItem.colorIndex = index
            return updatedItem
        }
    }
}
