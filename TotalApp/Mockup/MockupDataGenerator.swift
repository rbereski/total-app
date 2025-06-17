//
//  MockupDataGenerator.swift
//  TotalApp
//
//  Created by Rafal Bereski on 18/04/2025.
//

import Foundation
import SwiftData

public enum AssetPresets {
    private static let cryptoPrivderId = PriceDataProviderID.binance.id
    private static let stocksPrivderId = PriceDataProviderID.finnhub.id
    
    public static let cash1 = Asset(type: .cash, name: "Bank 1 (USD)", amount: 2000, currency: .usd, priceProviderId: nil, priceProviderSymbol: nil, position: 1)
    public static let cash2 = Asset(type: .cash, name: "Bank 1 (EUR)", amount: 1000, currency: .eur, priceProviderId: nil, priceProviderSymbol: nil, position: 2)
    public static let cash4 = Asset(type: .cash, name: "Bank 2 (USD)", amount: 500, currency: .usd, priceProviderId: nil, priceProviderSymbol: nil, position: 3)
    public static let cash3 = Asset(type: .cash, name: "Bank 2 (CHF)", amount: 1000, currency: .chf, priceProviderId: nil, priceProviderSymbol: nil, position: 4)
    
    public static let crypto1 = Asset(type: .crypto, name: "BTC Wallet", amount: 0.05, currency: .usd, priceProviderId: cryptoPrivderId, priceProviderSymbol: "BTC", position: 1)
    public static let crypto2 = Asset(type: .crypto, name: "ETH Wallet", amount: 2, currency: .usd, priceProviderId: cryptoPrivderId, priceProviderSymbol: "ETH", position: 2)
    public static let crypto3 = Asset(type: .crypto, name: "Exchange / ADA", amount: 2500, currency: .usd, priceProviderId: cryptoPrivderId, priceProviderSymbol: "ADA", position: 3)
    public static let crypto4 = Asset(type: .crypto, name: "Exchange / DOGE", amount: 1000, currency: .usd, priceProviderId: cryptoPrivderId, priceProviderSymbol: "DOGE", position: 4)
    public static let crypto5 = Asset(type: .crypto, name: "Exchange / USDT", amount: 1000, currency: .usd, priceProviderId: cryptoPrivderId, priceProviderSymbol: "USDT", position: 4)
    
    public static let stock1 = Asset(type: .stock, name: "Tesla", amount: 10, currency: .usd, priceProviderId: stocksPrivderId, priceProviderSymbol: "TSLA", position: 1)
    public static let stock2 = Asset(type: .stock, name: "nVidia", amount: 10, currency: .usd, priceProviderId: stocksPrivderId, priceProviderSymbol: "NVDA", position: 2)
    public static let stock3 = Asset(type: .stock, name: "Apple", amount: 10, currency: .usd, priceProviderId: stocksPrivderId, priceProviderSymbol: "AAPL", position: 3)
    
    public static let cash: [Asset] = [cash1, cash2, cash3, cash4]
    public static let crypto: [Asset] = [crypto1, crypto2, crypto3, crypto4, crypto5]
    public static let stocks: [Asset] = [stock1, stock2, stock3]
    public static let all: [Asset] =  cash + crypto + stocks
}

@MainActor
public class MockupDataGenerator {
    public let db: Database
    public let interval: Interval
    public let historyLength: Int
    public let currencies: [Currency]
    public let config: SnapshotsConfig
    public let generator: MockedSnapshotGenerator
    public let currencyConverter: MockedCurrencyConverter
    public let cryptoPriceProvider = MockedCryptoPriceProvider()
    public let stocksPriceProvider = MockedStocksPriceProvider()
    
    public init(db: Database, interval: Interval, historyLength: Int, currencies: [Currency]) {
        let priceDataProviders: PriceDataProvidersMap = .from([cryptoPriceProvider, stocksPriceProvider])
        self.currencyConverter = MockedCurrencyConverter(priceDataProviders: priceDataProviders)
        self.db = db
        self.interval = interval
        self.historyLength = historyLength
        self.currencies = currencies
        self.config = SnapshotsConfig(currencies: currencies, interval: interval, btcPriceProvider: .binance)
        self.generator = MockedSnapshotGenerator(currencyConverter: currencyConverter, priceDataProviders: priceDataProviders)
    }
    
    public convenience init(db: Database) {
        self.init(db: db, interval: .h24, historyLength: 30, currencies: [.eur, .pln, .czk])
    }
    
    public func resetData() throws {
        let ctx = db.mainContext
        try ctx.delete(model: SnapshotsConfigEntity.self)
        try ctx.delete(model: APIKeyEntity.self)
        try ctx.delete(model: AssetEntity.self)
        try ctx.delete(model: AssetValueEntity.self)
        try ctx.delete(model: CategoryValueEntity.self)
        try ctx.delete(model: TotalValueEntity.self)
        try ctx.save()
    }
    
    public func writeMockedData() throws {
        try resetData()
        
        currencyConverter.updateRatesSync()
        
        // Timestamp of the first interval
        let currentTs = interval.startTimestamp(ts: Timestamp.current)
        var snapshotTs = interval.relativeIntervalStartTimestamp(ts: currentTs, distance: -historyLength)
    
        // Save snapshots configuration
        let config = SnapshotsConfig(currencies: currencies, interval: interval, btcPriceProvider: .binance)
        let configEntity = SnapshotsConfigEntity(from: config)
        db.mainContext.insert(configEntity)
        try! db.mainContext.save()
      
        // Save mocked assets
        let assets = AssetPresets.all.map { Asset(asset: $0) }
        // let assets = [Asset]()
        for asset in assets {
            asset.modifiedTs = snapshotTs
            let entity = AssetEntity(from: asset)
            db.mainContext.insert(entity)
            try! db.mainContext.save()
            asset.persistentId = entity.persistentModelID
        }
        
        cryptoPriceProvider.initialTs = snapshotTs
        stocksPriceProvider.initialTs = snapshotTs
        
//        // Save historical snapshots
        while snapshotTs <= currentTs {
            currencyConverter.updateRatesSync()
            cryptoPriceProvider.currentTs = snapshotTs
            stocksPriceProvider.currentTs = snapshotTs
            let snapshot = try generator.generate(ts: snapshotTs, interval: interval, assets: assets, config: config)
            try db.mainContext.insert(snapshot: snapshot)
            snapshotTs = interval.relativeIntervalStartTimestamp(ts: snapshotTs, distance: 1)
        }
        
        try db.mainContext.save()
    }
}
