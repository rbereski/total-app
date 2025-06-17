//
//  SnapshotsManager.swift
//  TotalApp
//
//  Created by Rafal Bereski on 05/05/2025.
//

import Foundation
import Combine

@MainActor
public class SnapshotsManager {
    private let assetsStore: AssetsStore
    private let snapshotsStore: SnapshotsStore
    private let snapshotsStateTracker: SnapshotsStateTracker
    private let configManager: ConfigManager
    private let generator: SnapshotGenerator
    public private(set) var latestSnapshot: Snapshot?
    public let subject = CurrentValueSubject<Snapshot?, Never>(nil)
    
    public init(
        assetsStore: AssetsStore,
        snapshotsStore: SnapshotsStore,
        snapshotsStateTracker: SnapshotsStateTracker,
        configManager: ConfigManager,
        generator: SnapshotGenerator
    ) {
        self.assetsStore = assetsStore
        self.snapshotsStore = snapshotsStore
        self.snapshotsStateTracker = snapshotsStateTracker
        self.configManager = configManager
        self.generator = generator
    }
    
    public var snapshotsInterval: Interval {
        get async {
            let config = try? await configManager.snapshotsConfig
            return config?.interval ?? Consts.defaultSnapshotsInterval
        }
    }
    
    public func fetchLatestSnapshot() async throws {
        let snapshot = try await snapshotsStore.fetchLatestSnapshot()
        publish(snapshot: snapshot)
    }
    
    public func takeSnapshot() async throws(SnapshotError) {
        let ts = Timestamp.current
        let interval = await snapshotsInterval
        let assets: [Asset]
        
        do {
            assets = try await assetsStore.fetchAll()
        } catch let error {
            throw .databaseError(error)
        }
        
        let snapshot = try await generator.generate(ts: ts, interval:interval, assets: assets)
        
        do {
            try await snapshotsStore.save(snapshot: snapshot)
        } catch {
            throw .databaseError(error)
        }
        
        publish(snapshot: snapshot)
    }
    
    private func publish(snapshot: Snapshot) {
        latestSnapshot = snapshot
        snapshotsStateTracker.track(latestSnapshot: snapshot)
        subject.send(snapshot)
    }
    
    public func fetchTotalValues(startTs: Timestamp, endTs: Timestamp) async throws -> [TotalValue] {
        return try await snapshotsStore.fetchTotalValues(startTs: startTs, endTs: endTs)
    }
    
    public func fetchCategoryValues(startTs: Timestamp, endTs: Timestamp, assetType: AssetType) async throws -> [CategoryValue] {
        return try await snapshotsStore.fetchCategoryValues(startTs: startTs, endTs: endTs, assetType: assetType)
    }
    
    public func fetchTotalValues() async throws -> [TotalValue] {
        let interval = await snapshotsInterval
        let endTs = interval.startTimestamp(ts: Timestamp.current)
        let startTs = interval.relativeIntervalStartTimestamp(ts: endTs, distance: -30)
        return try await snapshotsStore.fetchTotalValues(startTs: startTs, endTs: endTs)
    }
}
