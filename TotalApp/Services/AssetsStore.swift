//
//  AssetsStore.swift
//  TotalApp
//
//  Created by Rafal Bereski on 10/04/2025.
//

import Foundation
import SwiftData

public class AssetsStore {
    private let db: Database
    
    public init(db: Database) {
        self.db = db
    }
    
    public func reset() async throws(DataStoreError) {
        do {
            try await db.background.withContext { _, ctx in
                try ctx.delete(model: AssetEntity.self)
            }
        } catch let error {
            throw .assetError("Error while resetting assets lists.", innerError: error)
        }
    }
    
    public func fetchAll() async throws(DataStoreError) -> [Asset] {
        do {
            return try await db.background.withContext { _, ctx in
                let fdAssets = FetchDescriptor<AssetEntity>()
                return try ctx.fetch(fdAssets).map { Asset(from: $0) }
            }
        } catch let error {
            throw .assetError("Error while fetching assets list.", innerError: error)
        }
    }
    
    public func save(assets: [Asset]) async throws(DataStoreError) {
        let itemsToInsert = assets.filter { $0.persistentId == nil }
        let itemsToUpdate = assets.filter { $0.persistentId != nil }
        
        do {
            try await db.background.withContext { _, ctx in
                let newEntities = itemsToInsert.map {
                    AssetEntity(from: $0)
                }
                
                for i in 0 ..< itemsToInsert.count {
                    ctx.insert(newEntities[i])
                }
                
                for asset in itemsToUpdate {
                    try ctx.update(asset: asset)
                }
                
                try ctx.save()
                
                for i in 0 ..< itemsToInsert.count {
                    itemsToInsert[i].persistentId = newEntities[i].persistentModelID
                }
            }
        } catch let error {
            throw .assetError("Error while saving/updating assets: \(assets.prefix(10).map(\.name).joined(separator: ", "))", innerError: error)
        }
    }
    
    public func delete(assets: [Asset]) async throws(DataStoreError) {
        do {
            try await db.background.withContext { _, ctx in
                try ctx.delete(assets: assets)
                try ctx.save()
            }
        } catch let error {
            throw .assetError("Error while deleting assets: \(assets.map(\.name).joined(separator: ", "))", innerError: error)
        }
    }
}

extension ModelContext {
    func update(asset: Asset) throws(DataStoreError) {
        guard let persistentId = asset.persistentId else {
            throw .assetError("Cannot update asset without persistent ID.")
        }
        
        guard let entity = self.model(for: persistentId) as? AssetEntity else {
            throw .assetError("Asset with persistent ID not found in the database.")
        }
        
        entity.applyChanges(asset)
    }
    
    func delete(assets: [Asset]) throws {
        let ids = assets.map(\.id)
        try delete(model: AssetEntity.self, where: #Predicate<AssetEntity> { ids.contains($0.id)})
    }
}
