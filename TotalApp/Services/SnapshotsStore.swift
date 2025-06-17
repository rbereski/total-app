//
//  SnapshotsStore.swift
//  TotalApp
//
//  Created by Rafal Bereski on 15/04/2025.
//

import Foundation
import SwiftData

public class SnapshotsStore {
    private let db: Database
    
    public init(db: Database) {
        self.db = db
    }
    
    public func reset() async throws(DataStoreError) {
        do {
            try await db.background.withContext { _, ctx in
                try ctx.delete(model: AssetValueEntity.self)
                try ctx.delete(model: CategoryValueEntity.self)
                try ctx.delete(model: TotalValueEntity.self)
            }
        } catch let error {
            throw .snapshotError("Error while resetting snapshots.", innerError: error)
        }
    }
    
    public func delete(snapshotWithTimestamp ts: Int) async throws(DataStoreError) {
        do {
            try await db.background.withContext { _, ctx in
                try ctx.delete(snapshotWithTimestamp: ts)
                try ctx.save()
            }
        } catch let error {
            throw .snapshotError("Error while deleting snapshot.", innerError: error)
        }
    }
    
    public func save(snapshot: Snapshot) async throws(DataStoreError) {
        try await delete(snapshotWithTimestamp: snapshot.totalValue.intervalTs)
        do {
            try await db.background.withContext { _, ctx in
                try ctx.insert(snapshot: snapshot)
                try ctx.save()
            }
        } catch let error {
            throw .snapshotError("Error while saving snapshot.", innerError: error)
        }
    }
    
    public func fetchTotalValues(startTs: Timestamp, endTs: Timestamp) async throws -> [TotalValue] {
        return try await db.background.withContext { _, ctx in
            let fd = FetchDescriptor<TotalValueEntity>(
                predicate: #Predicate<TotalValueEntity> { $0.intervalTs >= startTs && $0.intervalTs <= endTs },
                sortBy: [SortDescriptor(\.createdTs, order: .forward)]
            )
            let entries = try ctx.fetch(fd)
            return entries.map { TotalValue(from: $0) }
        }
    }
    
    public func fetchCategoryValues(startTs: Timestamp, endTs: Timestamp, assetType: AssetType) async throws -> [CategoryValue] {
        return try await db.background.withContext { _, ctx in
            let fd = FetchDescriptor<CategoryValueEntity>(
                predicate: #Predicate<CategoryValueEntity> { $0.intervalTs >= startTs && $0.intervalTs <= endTs && $0._assetType == assetType.rawValue },
                sortBy: [SortDescriptor(\.createdTs, order: .forward)]
            )
            let entries = try ctx.fetch(fd)
            return entries.map { CategoryValue(from: $0) }
        }
    }
    
    
    public func fetchLatestSnapshot() async throws(DataStoreError) -> Snapshot {
        guard let totalValue = try await fetchLastTotalValueLogEntry() else {
            throw .snapshotError("No snapshot available")
        }
        
        let createdTs = totalValue.createdTs
        let intervalTs = totalValue.intervalTs
        
        let fdCategories = FetchDescriptor<CategoryValueEntity>(
            predicate: #Predicate<CategoryValueEntity> { $0.createdTs == createdTs && $0.intervalTs == intervalTs }
        )
        
        let fdAssets = FetchDescriptor<AssetValueEntity>(
            predicate: #Predicate<AssetValueEntity> { $0.createdTs == createdTs && $0.intervalTs == intervalTs }
        )
        
        do {
            let categoriesValues = try await db.background.withContext { _, ctx in try ctx.fetch(fdCategories).map { CategoryValue(from: $0) } }
            let assetesValues = try await db.background.withContext { _, ctx in try ctx.fetch(fdAssets).map { AssetValue(from: $0) } }
            return Snapshot(assetValues: assetesValues, categoryValues: categoriesValues, totalValue: totalValue)
        } catch {
            throw .snapshotError("No snapshot available")
        }
    }
    
    private func fetchLastTotalValueLogEntry() async throws(DataStoreError) -> TotalValue? {
        do {
            return try await db.background.withContext { _, ctx in
                var fetchDescriptor = FetchDescriptor<TotalValueEntity>(sortBy: [SortDescriptor(\.createdTs, order: .reverse)])
                fetchDescriptor.fetchLimit = 1
                let entries = try ctx.fetch(fetchDescriptor)
                return entries.first.map { TotalValue(from: $0) }
            }
        } catch {
            throw .snapshotError("Error while reading most most recent total value.")
        }
    }
}

extension ModelContext {
    public func insert(snapshot: Snapshot) throws {
        try delete(snapshotWithTimestamp: snapshot.totalValue.intervalTs)
        
        insert(TotalValueEntity(from: snapshot.totalValue))
        
        for categoryValue in snapshot.categoryValues {
            insert(CategoryValueEntity(from: categoryValue))
        }
        
        for assetValue in snapshot.assetValues {
            insert(AssetValueEntity(from: assetValue))
        }
    }
    
    public func delete(snapshotWithTimestamp ts: Int) throws {
        try delete(model: AssetValueEntity.self, where: #Predicate<AssetValueEntity> { $0.intervalTs == ts })
        try delete(model: CategoryValueEntity.self, where: #Predicate<CategoryValueEntity> { $0.intervalTs == ts })
        try delete(model: TotalValueEntity.self, where: #Predicate<TotalValueEntity> { $0.intervalTs == ts })
    }
}
