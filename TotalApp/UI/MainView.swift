//
//  MainView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Environment(Services.self) private var services: Services
    @Environment(ViewSettings.self) private var viewSettings : ViewSettings
    @State var selection: AppSection = .overview
    
    var body: some View {
        TabView(selection: $selection) {
            Tab("Overview", systemImage: "chart.bar.xaxis", value: .overview) {
                OverviewView(
                    viewModel: OverviewViewModel(
                        assetsManager: services.assetsManager,
                        snapshotsManager: services.snapshotsManager,
                        viewSettings: viewSettings
                    )
                )
            }
            
            Tab("Assets", systemImage: "pencil.and.list.clipboard", value: .assetsList) {
                AssetsView(
                    viewModel: AssetsViewModel(
                        assetsManager: services.assetsManager,
                        snapshotsManager: services.snapshotsManager,
                        configManager: services.configManager,
                        viewSettings: viewSettings
                    )
                )
            }

            Tab("Settings", systemImage: "gearshape", value: .settings) {
                SettingsView(viewModel: SettingsViewModel(
                    configManager: services.configManager
                ))
            }
        }
        .preferredColorScheme(viewSettings.theme.colorScheme)
        .task { try? await services.snapshotsManager.fetchLatestSnapshot() }
    }
}


#Preview {
    let env = MockedEnvironment()
    MainView()
        .environment(env.services)
        .environment(env.viewSettings)
}
