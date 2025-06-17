//
//  APIKeysView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 24/05/2025.
//

import SwiftUI
import SwiftData

struct APIKeysView: View {
    @Environment(ViewSettings.self) private var viewSettings : ViewSettings
    @State var viewModel: SettingsViewModel
    @State var selection: APIKey?
    
    var body: some View {
        ZStack {
            AppBackground()
            if viewModel.hasKeys {
                VStack {
                    List(viewModel.apiKeysCategories, id: \.self) { category in
                        
                        if !viewModel.apiKeys[category, default: []].isEmpty {
                            Section(content: {
                                ForEach(viewModel.apiKeys[category, default: []], id: \.id) { apiKey in
                                    APIKeysListItemView(apiKey: apiKey, editAction: { selection = $0 })
                                }
                                .onDelete {
                                    viewModel.deleteKeys(category: category, indexSet: $0)
                                }
                                .selectionDisabled()
                            }, header: {
                                Text(category.categoryTitle)
                                    .listRowInsets(.init())
                            })
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .backgroundStyle(.clear)
                }
            } else {
                ContentUnavailableView(
                    "No API keys found",
                    systemImage: "key.horizontal",
                    description: Text("Use the (+) button to add one.")
                )
            }
        }
        .navigationTitle("API Keys")
        .toolbar { toolbarContent() }
        .sheet(item: $selection) { selected in
            EditAPIKeyView(viewModel: viewModel, apiKey: selected)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.loadApiKeys()
        }
    }
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(viewModel.apiProviders) { apiProvider in
                    Button(
                        action: { selection = APIKey(apiProvider: apiProvider) },
                        label: { Text(apiProvider.addKeyMenuItemTitle) }
                    )
                }
            }
            label: {
                Label("Add", systemImage: "plus")
            }
        }
    }
}


private extension APIProvider {
    var addKeyMenuItemTitle: String {
        switch self {
            case .freeCurrencyApi: "Free Currency API key"
            case .finnhub: "Finnhub API key"
            case .unspecified: "Custom API key"
        }
    }
}


