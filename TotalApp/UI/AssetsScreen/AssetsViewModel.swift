//
//  AssetsViewModel.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation
import Observation

@Observable
public class AssetListItem {
    let id: UUID
    let asset: Asset
    let values: [Currency : Double]
    let upToDate: Bool
    
    public init(asset: Asset, value: AssetValue?, supportedCurrencies: [Currency]) {
        self.id = asset.id
        self.asset = asset
        if let value = value {
            self.upToDate = asset.modifiedTs <= value.createdTs
            self.values = Dictionary(uniqueKeysWithValues: supportedCurrencies.enumerated().map { ($0.element, value.values[$0.offset]) })
        } else {
            self.upToDate = false
            self.values = [:]
        }
    }
}

public enum SymbolValidationResult {
    case recognized
    case unrecognized
    case providerNotConfigured
}

@MainActor
@Observable
public class AssetsViewModel {
    @ObservationIgnored private let assetsManager: AssetsManager
    @ObservationIgnored private let snapshotsManager: SnapshotsManager
    @ObservationIgnored private let configManager: ConfigManager
    @ObservationIgnored private let viewSettings: ViewSettings
    public private(set) var categories: [AssetType : [AssetListItem]] = [:]
    public private(set) var isEmpty: Bool = false
    
    public init(
        assetsManager: AssetsManager,
        snapshotsManager: SnapshotsManager,
        configManager: ConfigManager,
        viewSettings: ViewSettings
    ) {
        self.assetsManager = assetsManager
        self.snapshotsManager = snapshotsManager
        self.configManager = configManager
        self.viewSettings = viewSettings
    }
    
    public func refreshLists() async {
        categories = [
            .cash : createListItems(await assetsManager.getAssets(category: .cash)),
            .crypto : createListItems(await assetsManager.getAssets(category: .crypto)),
            .stock : createListItems(await assetsManager.getAssets(category: .stock)),
            .commodity : createListItems(await assetsManager.getAssets(category: .commodity)),
            .real : createListItems(await assetsManager.getAssets(category: .real)),
            .other : createListItems(await assetsManager.getAssets(category: .other))
        ]
        isEmpty = categories.allSatisfy({ $0.value.isEmpty })
    }
    
    public func refreshListsSync() {
        categories = [
            .cash : createListItems(assetsManager.getCachedAssets(category: .cash)),
            .crypto : createListItems(assetsManager.getCachedAssets(category: .crypto)),
            .stock : createListItems(assetsManager.getCachedAssets(category: .stock)),
            .commodity : createListItems(assetsManager.getCachedAssets(category: .commodity)),
            .real : createListItems(assetsManager.getCachedAssets(category: .real)),
            .other : createListItems(assetsManager.getCachedAssets(category: .other))
        ]
        isEmpty = categories.allSatisfy({ $0.value.isEmpty })
    }
    
    private func createListItems(_ assets: [Asset]) -> [AssetListItem] {
        let assetValuesMap = snapshotsManager.latestSnapshot?.assetValuesMap ?? [:]
        return assets.map { .init(asset: $0, value: assetValuesMap[$0.id], supportedCurrencies: viewSettings.supportedCurrencies) }
    }
    
    public func save(_ asset: Asset) async {
        do {
            try await assetsManager.save(asset: asset)
            await refreshLists()
        } catch {
            // TODO: Error handling
        }
    }
    
    public func move(from source: IndexSet, to destination: Int, category: AssetType) {
        Task {
            try? await assetsManager.move(from: source, to: destination, in: category)
            // TODO: Error handling
            refreshListsSync()
        }
    }
    
    public func delete(at indices: IndexSet, category: AssetType) {
        Task {
            let assets = await assetsManager.getAssets(category: category)
            let assetsToDelete = indices.map { assets[$0] }
            try? await assetsManager.delete(assets: assetsToDelete)
            // TODO: Error handling
            refreshListsSync()
        }
    }
    
    public func verify(assetSymbol: String, withProvider providerId: PriceDataProviderID) async -> SymbolValidationResult {
        guard providerId != .fixedPrice else {  return .recognized }
        guard !assetSymbol.isEmpty else { return .unrecognized }
        guard let provider = assetsManager.priceDataProviders[providerId] else { return .providerNotConfigured }
        
        do { try await provider.configure(with: configManager) }
        catch { return .providerNotConfigured }
        
        do {
            let result = try await provider.fetchPrice(symbol: assetSymbol)
            return result.price > 0 ? .recognized : .unrecognized
            
        } catch let error {
            if case .missingAPIKey = error { return .providerNotConfigured }
            if case .incorrectAPIKey = error { return .providerNotConfigured }
            return .recognized
        }
    }
}

