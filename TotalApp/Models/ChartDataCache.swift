//
//  ChartDataCache.swift
//  TotalApp
//
//  Created by Rafal Bereski on 05/06/2025.
//

import Foundation

public actor ChartDataCache<T : ValueLogEntry> {
    public typealias DataReader = (Timestamp, Timestamp) async throws -> [T]
    private let supportedCurrencies: [Currency]
    private let reader: DataReader
    public private(set) var chartInterval: Interval
    public private(set) var fetched = false
    private var cache: [T] = []

    
    public init(supportedCurrencies: [Currency], chartInterval: Interval, reader: @escaping DataReader) {
        self.supportedCurrencies = supportedCurrencies
        self.chartInterval = chartInterval
        self.reader = reader
    }
    
    public func append(_ item: T) {
        cache = cache.filter { $0.intervalTs != item.intervalTs }
        if let idx = cache.firstIndex(where: { $0.createdTs >= item.createdTs }) {
            cache[idx] = item
        } else {
            cache.append(item)
        }
    }
    
    public func refresh(snapshotsInterval: Interval, forced: Bool = false) async {
        let endTs = snapshotsInterval.startTimestamp(ts: Timestamp.current)
        let startTs = snapshotsInterval.startTimestamp(ts: max(0, endTs - chartInterval.duration))
        await loadData(startTs: startTs, endTs: endTs, chartInterval: chartInterval, forcedRefresh: forced)
    }
    
    public func getValues(chartInterval: Interval, snapshotsInterval: Interval, forcedRefresh: Bool = false) async -> PriceChartData {
        let endTs = snapshotsInterval.startTimestamp(ts: Timestamp.current)
        let startTs = snapshotsInterval.startTimestamp(ts: max(0, endTs - chartInterval.duration))
        await loadData(startTs: startTs, endTs: endTs, chartInterval: chartInterval, forcedRefresh: forcedRefresh)
        return await copyFromCache(starTs: startTs, endTs: endTs)
    }
    
    private func loadData(startTs: Timestamp, endTs: Timestamp, chartInterval: Interval, forcedRefresh: Bool) async {
        if !fetched || forcedRefresh || self.chartInterval.duration < chartInterval.duration {
            self.chartInterval = chartInterval
            if let data = try? await reader(startTs, endTs) {
                fetched = true
                cache = data
            } else {
                fetched = false
                cache = []
            }
        }
    }
    
    private func copyFromCache(starTs: Timestamp, endTs: Timestamp) async -> PriceChartData {
        var totalValues: [Currency: [TimeSeriesValue]] = [:]
        for (currIdx, currency) in self.supportedCurrencies.enumerated() {
            totalValues[currency] = cache
                .filter { $0.intervalTs >= starTs && $0.intervalTs <= endTs }
                .map { TimeSeriesValue(date: $0.createdTs.toDate(), value: $0.values[currIdx]) }
        }
        return totalValues
    }
}
