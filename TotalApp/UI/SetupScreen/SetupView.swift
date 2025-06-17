//
//  SetupView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 20/05/2025.
//

import SwiftUI
import SwiftData
import AlertToast

struct SetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ViewSettings.self) private var viewSettings : ViewSettings
    @Environment(AppInfo.self) private var appInfo: AppInfo
    @State var viewModel: SetupViewModel
    @State private var showCurrencySelector = false
    @State private var errorMessage = ""
    @State private var errorVisible = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                VStack {
                    List {
                        Section{
                            ForEach(viewModel.requiredCurrencies) { currency in
                                Text(currency.symbol)
                            }
                            ForEach(viewModel.optionalCurrencies) { currency in
                                Text(currency.symbol)
                            }
                            .onDelete { indexSet in
                                viewModel.optionalCurrencies.remove(atOffsets: indexSet)
                            }
                            .onMove { fromOffsets, toOffset in
                                viewModel.optionalCurrencies.move(fromOffsets: fromOffsets, toOffset: toOffset)
                            }
                            
                            if (viewModel.optionalCurrencies.count < Consts.maxOptionalCurrencies) {
                                Button(
                                    action: { showCurrencySelector = true },
                                    label: { Image(systemName: "plus") }
                                )
                            }
                        } header: {
                            Text("Snapshots Currencies")
                        } footer: {
                            Text("Currencies (up to 5) in which your portfolio value history will be tracked. **Important: The initial selection of currencies cannot be changed later.**")
                                .listRowInsets(.init(top: 12, leading: 12, bottom: 12, trailing: 12))
                                .font(.caption2)
                                .frame(maxWidth: .infinity)
                        }
                        
                        Section("Snapshots Interval") {
                            Picker("Interval", selection: $viewModel.snapshotsInterval) {
                                ForEach(Consts.snapshotIntervals) { interval in
                                    Text(interval.description).tag(interval)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        
                        Picker("Bitcoin Price Data Source", selection: $viewModel.btcPriceProvider) {
                            ForEach(viewModel.availableBTCPriceProviders, id: \.id) { provider in
                                Text(provider.providerName).tag(provider)
                            }
                        }
                        .pickerStyle(.inline)
                        
                        Section(
                            content: { TextField("API Key", text: $viewModel.freeCurrencyApiKey.bound) },
                            header: { Text("Free Currency API Key") },
                            footer: { Text("You can get a free key at [freecurrencyapi.com](https://freecurrencyapi.com)") }
                        )
                        
                        FormConfirmButton("Continue") {
                            Task {
                                await saveConfiguration()
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .backgroundStyle(.clear)
                }
            }
            .navigationTitle("First Launch Setup")
            .navigationDestination(isPresented: $showCurrencySelector) {
                SetupCurrencyPicker(
                    requiredCurrencies: $viewModel.requiredCurrencies,
                    optionalCurrencies: $viewModel.optionalCurrencies
                )
            }
            .toast(isPresenting: $errorVisible, duration: 2, tapToDismiss: true) {
                AlertToast(displayMode: .banner(.pop), type: .error(.red), title: errorMessage)
            }
        }
    }
    
    private func saveConfiguration() async {
        guard let apiKey = viewModel.freeCurrencyApiKey, !apiKey.isEmpty else {
            errorMessage = "Free Currency API key not entered."
            errorVisible = true
            return
        }
        
        guard await viewModel.checkFreeCurrencyAPIKey() else {
            errorMessage = "Incorrect Free Currency API key."
            errorVisible = true
            return
        }
        
        do {
            try await viewModel.saveConfiguration()
        } catch {
            errorMessage = "Error while saving configuration."
            errorVisible = true
            return
        }
        
        viewSettings.supportedCurrencies = viewModel.requiredCurrencies + viewModel.optionalCurrencies
        appInfo.appState = .ready
    }
}
