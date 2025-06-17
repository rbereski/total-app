//
//  MockedEnvironment.swift
//  TotalApp
//
//  Created by Rafal Bereski on 25/05/2025.
//

import Foundation
import SwiftData

@MainActor
public class MockedEnvironment {
    public let database: Database
    public let assetsStore: AssetsStore
    public let snapshotStore: SnapshotsStore
    public let configStore: ConfigStore
    public let services: Services
    public let viewSettings: ViewSettings
    
    public init() {
        let db = try! Database(inMemory: true)
        self.database = db
        
        let assetsStore = AssetsStore(db: db)
        let snapshotStore = SnapshotsStore(db: db)
        let configStore = ConfigStore(db: db)
        
        self.assetsStore = assetsStore
        self.snapshotStore = snapshotStore
        self.configStore = configStore
        
        let viewSettings = ViewSettings()
        self.viewSettings = viewSettings
        
        let priceDataProviders: PriceDataProvidersMap = .from([
            MockedCryptoPriceProvider(),
            MockedStocksPriceProvider()
        ])
        
        let currencyConverter = MockedCurrencyConverter(priceDataProviders: priceDataProviders)
        let snapshotsStateTracker = SnapshotsStateTracker()
        
        let configManager = ConfigManager(
            configStore: configStore,
            snapshotsStateTracker: snapshotsStateTracker
        )
        
        let assetsManager = AssetsManager(
            assetsStore: assetsStore,
            snapshotsStateTracker: snapshotsStateTracker,
            priceDataProviders: priceDataProviders
        )
        
        let generator =  SnapshotGenerator(
            configManager: configManager,
            currencyConverter: currencyConverter,
            priceDataProviders: priceDataProviders
        )
        
        let snapshotsManager = SnapshotsManager(
            assetsStore: assetsStore,
            snapshotsStore: snapshotStore,
            snapshotsStateTracker: snapshotsStateTracker,
            configManager: configManager,
            generator: generator
        )
        
        self.services = Services(
            snapshotsStateTracker: snapshotsStateTracker,
            snapshotsManager: snapshotsManager,
            assetsManager: assetsManager,
            configManager: configManager,
            fcaCurrencyConverter: currencyConverter
        )
        

        let initializer = MockupDataGenerator(db: db)
        try! initializer.writeMockedData()
        
        viewSettings.supportedCurrencies = initializer.config.supportedCurrencies
        snapshotsStateTracker.track(snapshotsInterval: initializer.interval)
    }
}
