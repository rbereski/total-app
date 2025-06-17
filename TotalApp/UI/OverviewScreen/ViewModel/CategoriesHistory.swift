//
//  CategoriesHistory.swift
//  TotalApp
//
//  Created by Rafal Bereski on 06/06/2025.
//

import Foundation
import Observation


@MainActor
@Observable
public class CategoriesHistory: HistoryChartModel {
    private let snapshotsManager: SnapshotsManager
    private let viewSettings: ViewSettings
    private let supportedCurrencies: [Currency]
    public private(set) var chartInterval: Interval
    public private(set) var values: [AssetType: PriceChartData]
    public private(set) var hasEnoughData: Bool = false
    private let caches: [AssetType : ChartDataCache<CategoryValue>]
    
    public init(snapshotsManager: SnapshotsManager, viewSettings: ViewSettings) {
        var caches: [AssetType : ChartDataCache<CategoryValue>] = [:]
        var values: [AssetType : PriceChartData] = [:]
        for assetType in AssetType.assetsVithValue {
            values[assetType] = Dictionary(uniqueKeysWithValues: viewSettings.supportedCurrencies.map { ($0, []) })
            caches[assetType] = ChartDataCache(
                supportedCurrencies: viewSettings.supportedCurrencies,
                chartInterval: viewSettings.categoriesValueChartInterval,
                reader: { try await snapshotsManager.fetchCategoryValues(startTs: $0, endTs: $1, assetType: assetType) }
            )
        }
        self.snapshotsManager = snapshotsManager
        self.viewSettings = viewSettings
        self.supportedCurrencies = viewSettings.supportedCurrencies
        self.chartInterval = viewSettings.categoriesValueChartInterval
        self.values = values
        self.caches = caches
    }
    
    public func fetchIfNeeded() async {
        let snapshotsInterval = await snapshotsManager.snapshotsInterval
        for assetType in AssetType.assetsVithValue {
            let isFetched = (await caches[assetType]?.fetched) ?? true
            let isEmpty = values[assetType]?.isEmpty ?? true
            if !isFetched || isEmpty {
                await updateValues(assetType: assetType, snapshotsInterval: snapshotsInterval)
            }
        }
    }
    
    public func set(chartInterval: Interval) async {
        let snapshotsInterval = await snapshotsManager.snapshotsInterval
        self.chartInterval = chartInterval
        self.viewSettings.categoriesValueChartInterval = chartInterval
        for assetType in AssetType.assetsVithValue {
            await updateValues(assetType: assetType, snapshotsInterval: snapshotsInterval)
        }
    }
    
    public func append(snapshot: Snapshot) async {
        let snapshotsInterval = await snapshotsManager.snapshotsInterval
        for categoryValue in snapshot.categoryValues {
            await caches[categoryValue.assetType]?.append(categoryValue)
            await updateValues(assetType: categoryValue.assetType, snapshotsInterval: snapshotsInterval)
        }
    }
    
    private func updateValues(assetType: AssetType, snapshotsInterval: Interval) async {
        guard let cache = caches[assetType] else { return }
        values[assetType] = await cache.getValues(chartInterval: chartInterval, snapshotsInterval: snapshotsInterval)
        hasEnoughData = values.values.filter({ ($0.first?.value ?? []).count >= 2 }).count >= 1
    }
}
