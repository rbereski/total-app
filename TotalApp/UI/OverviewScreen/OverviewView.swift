//
//  OverviewView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import SwiftUI
import Charts
import AlertToast

struct OverviewView: View {
    @Environment(Services.self) private var services: Services
    @Environment(ViewSettings.self) private var viewSettings: ViewSettings
    @Bindable private var viewModel: OverviewViewModel
    @State private var isGeneratingSnapshot: Bool = false
    
    init(viewModel: OverviewViewModel) {
        self._viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            AppBackground()
            
            ScrollView {
                VStack(spacing: 16) {
                    @Bindable var viewSettings = viewSettings
                    
                    CurrencyPickerWidget(
                        selectedCurrency: $viewSettings.selectedCurrency,
                        supportedCurrencies: viewSettings.supportedCurrencies,
                        action: { viewModel.selectCurrency($0) }
                    )
                    
                    TotaValueWidget(
                        snapshotOverview: viewModel.snapshotOverview,
                        selectedCurrency: $viewSettings.selectedCurrency,
                        snapshotState: services.snapshotsStateTracker.state
                    )
                    
                    SnapshotButton {
                        Task {
                            withAnimation { isGeneratingSnapshot = true }
                            await viewModel.takeSnapshot()
                            withAnimation { isGeneratingSnapshot = false }
                        }
                    }
                    
                    OverviewSection(title: "Total Value History") {
                        TotalValueHistoryWidget(chartModel: viewModel.totalHistory)
                            .frame(maxHeight: 240)
                    }
                    
                    if viewModel.snapshotOverview.hasCategoriesSummary {
                        OverviewSection(title: "Portfolio Allocation") {
                            PortfolioAllocationWidget(snapshotOverview: viewModel.snapshotOverview)
                        }
                    }
                    
                    OverviewSection(title: "Asset Classes History") {
                        CategoriesHistoryWidget(chartModel: viewModel.categoriesHistory)
                    }
                    
                    if viewModel.snapshotOverview.hasCurrenciesSummary {
                        OverviewSection(title: "Cash Allocation") {
                            SymbolsAllocationWidget(summary: viewModel.snapshotOverview.cashAllocation)
                        }
                    }
                    
                    if viewModel.snapshotOverview.hasCryptoSummary {
                        OverviewSection(title: "Crypto Allocation") {
                            SymbolsAllocationWidget(summary: viewModel.snapshotOverview.cryptoAllocation)
                        }
                    }
                    
                    if viewModel.snapshotOverview.hasStocksSummary {
                        OverviewSection(title: "Stocks Allocation") {
                            SymbolsAllocationWidget(summary: viewModel.snapshotOverview.stocksAllocation)
                        }
                    }

                    Spacer()
                }
                .disabled(isGeneratingSnapshot)
            }
            .scrollIndicators(.hidden)
            .padding(.horizontal, 16)
            
            if isGeneratingSnapshot {
                SnapshotProgressOverlay()
                    .zIndex(100)
                    .transition(.move(edge: .bottom))
            }
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Snapshot Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK")) {
                    viewModel.showError = false
                }
            )
        }
        .task {
            await viewModel.refresh()
            viewModel.listenForNewSnapshots()
        }
    }
}


#Preview {
    let env = MockedEnvironment()
    ZStack {
        OverviewView(
            viewModel: OverviewViewModel(
                assetsManager: env.services.assetsManager,
                snapshotsManager: env.services.snapshotsManager,
                viewSettings: env.viewSettings
            )
        )
        .environment(env.services)
        .environment(env.viewSettings)
    }.task {
        try? await env.services.snapshotsManager.fetchLatestSnapshot()
    }
}
