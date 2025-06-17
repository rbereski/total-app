//
//  MockedCryptoPriceProvider.swift
//  TotalApp
//
//  Created by Rafal Bereski on 25/05/2025.
//

import Foundation

public class MockedStocksPriceProvider: MockedPriceDataProviderType {
    public let id: PriceDataProviderID = .finnhub
    public var initialTs: Timestamp = .current
    public var currentTs: Timestamp = .current
    
    public init() {
        /* Empty */
    }
    
    public func configure(with configManager: ConfigManager) async throws(DataProviderError) {
        /* Empty */
    }
    
    public func fetchPrice(symbol: String) async throws(DataProviderError) -> AssetPrice {
        return fetchPriceSync(symbol: symbol)
    }
    
    public func fetchPriceSync(symbol: String) -> AssetPrice {
        let interval = Interval.h12
        let intervalsDiff = Double((interval.startTimestamp(ts: currentTs) - interval.startTimestamp(ts: initialTs)) / interval.duration)
        let price = mockedInitialPrice(symbol: symbol) * (1 + sin(intervalsDiff / 5.0) / 4.0 + intervalsDiff * 0.02)
        return AssetPrice(symbol: symbol, price: price, currency: .usd, timestamp: currentTs)
    }
    
    private func mockedInitialPrice(symbol: String) -> Double {
        switch symbol {
            case "NVDA": return 120
            case "AAPL": return 180
            case "TSLA": return 240
            case "AMD": return 100
            default: return 50.0
        }
    }
}
