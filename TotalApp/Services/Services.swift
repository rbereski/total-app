//
//  Services.swift
//  TotalApp
//
//  Created by Rafal Bereski on 06/05/2025.
//

import Observation

@Observable
public class Services {
    public let snapshotsStateTracker: SnapshotsStateTracker
    public let snapshotsManager: SnapshotsManager
    public let assetsManager: AssetsManager
    public let configManager: ConfigManager
    public let fcaCurrencyConverter: CurrencyConverterType
    
    public init(
        snapshotsStateTracker: SnapshotsStateTracker,
        snapshotsManager: SnapshotsManager,
        assetsManager: AssetsManager,
        configManager: ConfigManager,
        fcaCurrencyConverter: CurrencyConverterType
    ) {
        self.snapshotsStateTracker = snapshotsStateTracker
        self.snapshotsManager = snapshotsManager
        self.assetsManager = assetsManager
        self.configManager = configManager
        self.fcaCurrencyConverter = fcaCurrencyConverter
    }
}
