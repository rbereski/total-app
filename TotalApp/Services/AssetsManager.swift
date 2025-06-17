//
//  AssetsManager.swift
//  TotalApp
//
//  Created by Rafal Bereski on 08/05/2025.
//

import Foundation

@MainActor
public class AssetsManager {
    private let assetsStore: AssetsStore
    private let snapshotsStateTracker: SnapshotsStateTracker
    public let priceDataProviders: PriceDataProvidersMap
    private var fetched: Bool = false
    private var assets: [UUID: Asset] = [:]
    private var assetCategories: [AssetType : [Asset]] = [:]
    
    public init(
        assetsStore: AssetsStore,
        snapshotsStateTracker: SnapshotsStateTracker,
        priceDataProviders: PriceDataProvidersMap
    ) {
        self.assetsStore = assetsStore
        self.snapshotsStateTracker = snapshotsStateTracker
        self.priceDataProviders = priceDataProviders
    }
    
    public func getAsset(id: UUID) async -> Asset? {
        await loadAssetsIfNeeded()
        return assets[id]
    }
    
    public func getAsset(at index: Int, in category: AssetType) -> Asset? {
        return assetCategories[category]?[index]
    }
    
    public func getAssets(category: AssetType) async -> [Asset] {
        await loadAssetsIfNeeded()
        return assetCategories[category] ?? []
    }
    
    public func getCachedAssets(category: AssetType) -> [Asset] {
        return assetCategories[category] ?? []
    }
    
    private func loadAssetsIfNeeded() async {
        guard !fetched else { return }
        await loadAssets()
    }

    private func loadAssets() async {
        do {
            let assets = try await assetsStore.fetchAll()
            processLoadedAssets(assets)
            fetched = true
        } catch {
            processLoadedAssets([])
            fetched = false
        }
    }
    
    public func save(asset: Asset) async throws(DataStoreError) {
        await loadAssetsIfNeeded()
        let isNew = !assets.keys.contains(asset.id)
        
        asset.modifiedTs = Timestamp.current
        snapshotsStateTracker.track(assetModificationTs: asset.modifiedTs)
        
        if isNew {
            asset.position = nextPositionNumber(forCategory: asset.type)
        }
        
        try await assetsStore.save(assets: [asset])
        
        if !isNew {
            let replaced = assets[asset.id]!
            assets[asset.id] = asset
            if let indexInGroup = assetCategories[asset.type]?.firstIndex(where: { $0.id == asset.id }) {
                assetCategories[asset.type]?[indexInGroup] = asset
                if replaced.position != asset.position {
                    sortByPositionAndName(&assetCategories[asset.type]!)
                }
            }
        } else {
            assets[asset.id] = asset
            assetCategories[asset.type]?.append(asset)
            sortByPositionAndName(&assetCategories[asset.type]!)
        }
    }
    
    public func delete(assets: [Asset]) async throws(DataStoreError) {
        guard !assets.isEmpty else { return }
        await loadAssetsIfNeeded()
        try await assetsStore.delete(assets: assets)
        snapshotsStateTracker.track(assetModificationTs: Timestamp.current)
        for asset in assets {
            self.assets.removeValue(forKey: asset.id)
            if let idx = assetCategories[asset.type]?.firstIndex(where: { $0.id == asset.id }) {
                assetCategories[asset.type]?.remove(at: idx)
            }
        }
    }
    
    public func move(from source: IndexSet, to destination: Int, in category: AssetType) async throws {
        assetCategories[category]?.move(fromOffsets: source, toOffset: destination)
        for (index, asset) in (assetCategories[category] ?? []).enumerated() {
            asset.position = index + 1
        }
        try await assetsStore.save(assets: assetCategories[category] ?? [])
    }
    
    private func processLoadedAssets(_ assets: [Asset]) {
        self.assets = [:]
        self.assetCategories = [:]
        
        snapshotsStateTracker.track(
            assetModificationTs: assets.map(\.modifiedTs).max() ?? 0
        )
        
        for asset in assets {
            self.assets[asset.id] = asset
        }
        
        for type in AssetType.allCases {
            self.assetCategories[type] = assets
                .filter { $0.type == type }
                .sorted(by: { $0.position < $1.position })
        }
    }
    
    private func sortByPositionAndName(_ array: inout [Asset]) {
        array.sort {
            ($0.position != $1.position)
                ? $0.position < $1.position
                : $0.name < $1.name
        }
    }
    
    private func nextPositionNumber(forCategory category: AssetType) -> Int {
       (assetCategories[category]?.map({ $0.position }).max() ?? 0) + 1
    }
}
