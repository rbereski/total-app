//
//  ConfigStore.swift
//  TotalApp
//
//  Created by Rafal Bereski on 17/04/2025.
//

import Foundation
import SwiftData

public class ConfigStore {
    private let db: Database
    private var _snapshotConfig: SnapshotsConfig?
    
    public init(db: Database) {
        self.db = db
    }
    
    public func reset() async throws(DataStoreError) {
        try await resetConfig()
        try await resetAPIKeys()
    }
    
    public var snapshotConfig : SnapshotsConfig? {
        get async throws(DataStoreError) {
            if _snapshotConfig == nil {
                _snapshotConfig = try await loadSnapshotsConfig()
            }
            return _snapshotConfig
        }
    }
    
    private func resetConfig() async throws(DataStoreError) {
        do {
            try await db.background.delete(model: SnapshotsConfigEntity.self)
        } catch let error {
            throw .configError("Error while resetting snapshots configuration.", innerError: error)
        }
    }
    
    public func save(snapshotsConfig config: SnapshotsConfig) async throws(DataStoreError)  {
        do {
            self._snapshotConfig = nil
            try await resetConfig()
            let entity = SnapshotsConfigEntity(from: config)
            await db.background.insert(entity)
            try await db.background.save()
        } catch let error {
            throw .configError("Error while saving snapshots configuration.", innerError: error)
        }
    }
    
    private func loadSnapshotsConfig() async throws(DataStoreError) -> SnapshotsConfig? {
        do {
            return try await db.background.withContext { _, ctx in
                try ctx.fetchOne().map { SnapshotsConfig(from: $0) }
            }
        } catch let error {
            throw .configError("Error while reading snapshots configuration.", innerError: error)
        }
    }
    
    private func resetAPIKeys() async throws(DataStoreError) {
        do {
            try await db.background.delete(model: APIKeyEntity.self)
        } catch let error {
            throw .apiKeysError("Error while resetting API keys.", innerError: error)
        }
    }
    
    public func fetchAPIKeys() async throws(DataStoreError) -> [APIKey] {
        do {
            return try await db.background.withContext { _, ctx in
                let fd = FetchDescriptor<APIKeyEntity>()
                return try ctx.fetch(fd).map { APIKey(from: $0) }
            }
        } catch let error {
            throw .apiKeysError("Error while fetching API keys.", innerError: error)
        }
    }
    
    public func save(apiKeys: [APIKey]) async throws(DataStoreError)  {
        let itemsToInsert = apiKeys.filter { $0.persistentId == nil }
        let itemsToUpdate = apiKeys.filter { $0.persistentId != nil }
        do {
            try await db.background.withContext { _, ctx in
                let newEntities = itemsToInsert.map {
                    APIKeyEntity(from: $0)
                }
                
                for i in 0 ..< itemsToInsert.count {
                    ctx.insert(newEntities[i])
                }
                
                for item in itemsToUpdate {
                    try ctx.update(apiKey: item)
                }
                
                try ctx.save()
                
                for i in 0 ..< itemsToInsert.count {
                    itemsToInsert[i].persistentId = newEntities[i].persistentModelID
                }
            }
        } catch let error {
            throw .apiKeysError("Error while saving/updating API keys: \(apiKeys.prefix(10).map(\.id).joined(separator: ", ")).", innerError: error)
        }
    }
    
    public func delete(apiKeys: [APIKey]) async throws(DataStoreError) {
        do {
            try await db.background.withContext { _, ctx in
                try ctx.delete(apiKeys: apiKeys)
                try ctx.save()
            }
        } catch let error {
            throw .apiKeysError("Error while deleting API keys: \(apiKeys.prefix(10).map(\.id).joined(separator: ", ")).", innerError: error)
        }
    }
}

extension ModelContext {
    func update(apiKey: APIKey) throws(DataStoreError) {
        guard let persistentId = apiKey.persistentId else {
            throw .apiKeysError("Cannot update API key without persistent ID.")
        }
        
        guard let entity = self.model(for: persistentId) as? APIKeyEntity else {
            throw .apiKeysError("API key with persistent ID not found in the database.")
        }
        
        entity.applyChanges(apiKey)
    }
    
    func delete(apiKeys: [APIKey]) throws {
        let ids = apiKeys.map(\.id)
        try delete(model: APIKeyEntity.self, where: #Predicate<APIKeyEntity> { ids.contains($0.id)})
    }
}
