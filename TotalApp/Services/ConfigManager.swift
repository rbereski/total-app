//
//  ConfigManager.swift
//  TotalApp
//
//  Created by Rafal Bereski on 20/05/2025.
//

public enum ConfigError : Error {
    case snapshotConfigSaveError(_ innerError: DataStoreError)
    case apiKeySaveError(_ innerError: DataStoreError)
    case apiKeyDeletetionError(_ innerError: DataStoreError)
    case apiKeyAlreadyExists
    
    var description: String {
        switch self {
            case .snapshotConfigSaveError:
                return "Cannot save snapshots configuration."
            case .apiKeySaveError:
                return "Cannot save API key."
            case .apiKeyDeletetionError:
                return "Cannot delete API keys."
            case .apiKeyAlreadyExists:
                return "API key already exists."
        }
    }
}

@MainActor
public class ConfigManager {
    private let configStore: ConfigStore
    private let snapshotsStateTracker: SnapshotsStateTracker
    private var apiKeys: [APIKey]? = nil
    
    public init(configStore: ConfigStore, snapshotsStateTracker: SnapshotsStateTracker) {
        self.configStore = configStore
        self.snapshotsStateTracker = snapshotsStateTracker
    }
    
    public var snapshotsConfig: SnapshotsConfig? {
        get async throws(DataStoreError) {
            try await configStore.snapshotConfig
        }
    }
    
    public func save(snapshotsConfig: SnapshotsConfig) async throws(ConfigError) {
        do {
            try await configStore.save(snapshotsConfig: snapshotsConfig)
            snapshotsStateTracker.track(snapshotsInterval: snapshotsConfig.interval)
        } catch let e {
            throw .snapshotConfigSaveError(e)
        }
    }
    
    public func getAPIKeys() async -> [APIKey] {
        await loadAPIKeysIfNeeded()
        return apiKeys ?? []
    }
    
    public func getAPIKey(forProvider provider: APIProvider) async -> APIKey? {
        await loadAPIKeysIfNeeded()
        return apiKeys?.first(where: { $0.provider == provider })
    }
    
    public func save(apiKey: APIKey, overwriteExisting: Bool = false) async throws (ConfigError) {
        await loadAPIKeysIfNeeded()
        let existingApiKey = apiKeys?.first(where: { $0.id == apiKey.id })
        
        if let existingApiKey, existingApiKey.persistentId != apiKey.persistentId {
            if !overwriteExisting {
                throw .apiKeyAlreadyExists
            } else {
                try await delete(apiKeys: [existingApiKey])
            }
        }
        
        try await save(apiKeys: [apiKey])
    }
    
    private func save(apiKeys: [APIKey]) async throws(ConfigError) {
        do {
            try await configStore.save(apiKeys: apiKeys)
            await loadAPIKeys()
        } catch let e {
            throw .apiKeySaveError(e)
        }
    }
    
    public func delete(apiKeys: [APIKey]) async throws (ConfigError) {
        do {
            await loadAPIKeysIfNeeded()
            try await configStore.delete(apiKeys: apiKeys)
            await loadAPIKeys()
        } catch let e {
            throw .apiKeyDeletetionError(e)
        }
    }
    
    private func loadAPIKeysIfNeeded() async {
        guard apiKeys == nil else { return }
        await loadAPIKeys()
    }

    private func loadAPIKeys() async {
        apiKeys = (try? await configStore.fetchAPIKeys()) ?? []
    }
}
