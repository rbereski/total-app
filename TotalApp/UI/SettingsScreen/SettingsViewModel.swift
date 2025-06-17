//
//  SettingsViewModel.swift
//  TotalApp
//
//  Created by Rafal Bereski on 24/05/2025.
//

import Foundation
import Observation

@MainActor
@Observable
public class SettingsViewModel {
    private let configManager: ConfigManager
    public let availableBTCPriceProviders = PriceDataProviderID.btcPriceProviders
    public var snapshotsInterval: Interval = Consts.defaultSnapshotsInterval
    public var btcPriceProvider: PriceDataProviderID = Consts.defaultBtcPriceProvider
    public let apiProviders: [APIProvider] = APIProvider.allCases
    public let apiKeysCategories: [APIProviderType] = APIProviderType.allCases
    public var apiKeys: [APIProviderType: [APIKey]] = [:]
    public var hasKeys: Bool = false
    
    public init(configManager: ConfigManager) {
        self.configManager = configManager
    }
    
    public func loadConfiguration() async {
        guard let config = try? await configManager.snapshotsConfig else { return }
        btcPriceProvider = config.btcPriceProvider
        snapshotsInterval = config.interval
    }
    
    public func saveConfiguration() async {
        guard let config = try? await configManager.snapshotsConfig else { return }
        config.btcPriceProvider = btcPriceProvider
        config.interval = snapshotsInterval
        try? await configManager.save(snapshotsConfig: config)
    }
    
    public func loadApiKeys() async {
        let allKeys = await configManager.getAPIKeys()
        var apiKeys: [APIProviderType: [APIKey]] = [:]
        
        for key in allKeys {
            apiKeys[key.provider.type, default: []].append(key)
        }
        
        self.apiKeys = apiKeys
        self.hasKeys = !allKeys.isEmpty
    }
    
    public func deleteKeys(category: APIProviderType, indexSet: IndexSet) {
        Task {
            let keys = indexSet.map { apiKeys[category, default: []][$0] }
            try await configManager.delete(apiKeys: keys)
            await loadApiKeys()
        }
    }
    
    public func save(apiKey: APIKey) async throws(ConfigError) {
        try await configManager.save(apiKey: apiKey)
        await loadApiKeys()
    }
}
