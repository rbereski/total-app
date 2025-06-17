//
//  OverviewViewModel.swift
//  TotalApp
//
//  Created by Rafal Bereski on 04/05/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
@Observable
public class OverviewViewModel {
    @ObservationIgnored private let assetsManager: AssetsManager
    @ObservationIgnored private let snapshotsManager: SnapshotsManager
    @ObservationIgnored private var viewSettings: ViewSettings
    @ObservationIgnored private var cancellables: Set<AnyCancellable> = []
    @ObservationIgnored private var listenersConfigured = false

    let snapshotOverview: SnapshotOverview
    let totalHistory: TotalValueHistory
    let categoriesHistory: CategoriesHistory
    var showError: Bool = false
    var errorMessage: String = ""
    
    public init(
        assetsManager: AssetsManager,
        snapshotsManager: SnapshotsManager,
        viewSettings: ViewSettings
    ) {
        self.assetsManager = assetsManager
        self.snapshotsManager = snapshotsManager
        self.viewSettings = viewSettings
        self.snapshotOverview = SnapshotOverview(assetsManager: assetsManager, supportedCurrencies: viewSettings.supportedCurrencies)
        self.totalHistory = TotalValueHistory(snapshotsManager: snapshotsManager, viewSettings: viewSettings)
        self.categoriesHistory = CategoriesHistory(snapshotsManager: snapshotsManager, viewSettings: viewSettings)
    }
    
    public func refresh() async {
        await totalHistory.fetchIfNeeded()
        await categoriesHistory.fetchIfNeeded()
    }
    
    public func listenForNewSnapshots() {
        guard !listenersConfigured else { return }
        listenersConfigured = true
        cancellables.forEach { $0.cancel()}
        cancellables.removeAll()
        self.snapshotsManager.subject.sink { [weak self] snapshot in
            guard let self else { return }
            Task { [weak self] in await self?.processNewSnapshot(snapshot) }
        }.store(in: &cancellables)
    }
    
    public func selectCurrency(_ currency: Currency) {
        viewSettings.selectedCurrency = currency
        viewSettings.save()
    }
    
    private func processNewSnapshot(_ snapshot: Snapshot?) async {
        guard let snapshot = snapshot else { return }
        await snapshotOverview.update(snapshot: snapshot)
        await totalHistory.append(snapshot: snapshot)
        await categoriesHistory.append(snapshot: snapshot)
    }
    
    public func takeSnapshot() async  {
        do {
            try? await Task.sleep(for: .seconds(0.6))
            try await snapshotsManager.takeSnapshot()
        } catch let e {
            errorMessage = [e.errorDescription, e.recoverySuggestion]
                .compactMap(\.self)
                .joined(separator: "\n")
            showError = true
        }
    }
}
