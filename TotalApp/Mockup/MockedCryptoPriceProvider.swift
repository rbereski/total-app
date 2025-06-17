//
//  MockedCryptoPriceProvider.swift
//  TotalApp
//
//  Created by Rafal Bereski on 25/05/2025.
//

import Foundation

public class MockedCryptoPriceProvider: MockedPriceDataProviderType {
    public let id: PriceDataProviderID = .binance
    public var initialTs: Timestamp = .current
    public var currentTs: Timestamp = .current
    public init() { /* Empty */ }
    
    public func configure(with configManager: ConfigManager) async throws(DataProviderError) {
        /* Empty */
    }
    
    public func fetchPrice(symbol: String) async throws(DataProviderError) -> AssetPrice {
        return fetchPriceSync(symbol: symbol)
    }
    
    public func fetchPriceSync(symbol: String) -> AssetPrice {
        if symbol.hasPrefix("USD") {
            return AssetPrice(symbol: symbol, price: 1.0, currency: .usd, timestamp: currentTs)
        }
        
        let interval = Interval.h12
        let intervalsDiff = Double((interval.startTimestamp(ts: currentTs) - interval.startTimestamp(ts: initialTs)) / interval.duration)
        let price = mockedInitialPrice(symbol: symbol) * (1 + sin(intervalsDiff / 5.0) / 4.0 + intervalsDiff * 0.02)
        return AssetPrice(symbol: symbol, price: price, currency: .usd, timestamp: currentTs)
    }
    
    private func mockedInitialPrice(symbol: String) -> Double {
        switch symbol {
            case "BTC": return 35000
            case "ETH": return 1200
            case "ADA": return 0.421
            case "XRP": return 0.467
            case "DOGE": return 0.1900
            default: return 1.0
        }
    }
}
