//
//  TotalValueHistory.swift
//  TotalApp
//
//  Created by Rafal Bereski on 27/05/2025.
//

import Foundation
import Observation

@MainActor
@Observable
public class TotalValueHistory: HistoryChartModel {
    private let snapshotsManager: SnapshotsManager
    private let viewSettings: ViewSettings
    private let supportedCurrencies: [Currency]
    public private(set) var chartInterval: Interval
    public private(set) var values: PriceChartData = [:]
    public private(set) var hasEnoughData: Bool = false
    private let cache: ChartDataCache<TotalValue>
    
    public init(snapshotsManager: SnapshotsManager, viewSettings: ViewSettings) {
        self.snapshotsManager = snapshotsManager
        self.viewSettings = viewSettings
        self.supportedCurrencies = viewSettings.supportedCurrencies
        self.chartInterval = viewSettings.totalValueChartInterval
        self.cache = ChartDataCache(
            supportedCurrencies: viewSettings.supportedCurrencies,
            chartInterval: viewSettings.totalValueChartInterval,
            reader: { try await snapshotsManager.fetchTotalValues(startTs: $0, endTs: $1)  }
        )
    }
    
    public func fetchIfNeeded() async {
        if (!(await cache.fetched) || values.isEmpty) {
            await updateValues()
        }
    }
    
    public func set(chartInterval : Interval) async {
        self.chartInterval = chartInterval
        self.viewSettings.totalValueChartInterval = chartInterval
        await updateValues()
    }
    
    public func append(snapshot: Snapshot) async {
        await cache.append(snapshot.totalValue)
        await updateValues()
    }
    
    private func updateValues() async {
        values = await cache.getValues(
            chartInterval: chartInterval,
            snapshotsInterval: await self.snapshotsManager.snapshotsInterval
        )
        hasEnoughData = values.first?.value.count ?? 0 >= 2
    }
}
