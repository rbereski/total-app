//
//  SettingsView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 24/05/2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(ViewSettings.self) private var viewSettings : ViewSettings
    @State var viewModel: SettingsViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                VStack {
                    List {
                        Section("Appearance") {
                            @Bindable var viewSettings = viewSettings
                            Picker("Theme", selection: $viewSettings.theme) {
                                ForEach(Theme.all) { theme in
                                    Text(theme.name).tag(theme)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Section("Snapshots") {
                            Picker("Interval", selection: $viewModel.snapshotsInterval) {
                                ForEach(Consts.snapshotIntervals) { interval in
                                    Text(interval.description).tag(interval)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Picker("Bitcoin Price Data Source", selection: $viewModel.btcPriceProvider) {
                            ForEach(viewModel.availableBTCPriceProviders) { provider in
                                Text(provider.providerName).tag(provider)
                            }
                        }
                        .pickerStyle(.inline)
                        
                        Section("Other Settings") {
                            NavigationLink("API Keys") {
                                APIKeysView(viewModel: viewModel)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .backgroundStyle(.clear)
                }
            }
            .navigationTitle("Settings")
            .onChange(of: viewSettings.theme) { _, _ in viewSettings.save() }
            .onChange(of: viewModel.snapshotsInterval) { _, _ in Task { await viewModel.saveConfiguration() } }
            .onChange(of: viewModel.btcPriceProvider) { _, _ in Task { await viewModel.saveConfiguration() } }
        }
        .task { await viewModel.loadConfiguration() }
    }
}
