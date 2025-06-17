//
//  App.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import SwiftUI

let USE_MOCKUP_DATA = false

@main
struct TotalApp: App {
    private var appInfo = AppInfo()
    private var viewSettings = ViewSettings()
    private var services: Services!
    
    init() {
        
        if USE_MOCKUP_DATA {
            viewSettings.reset()
        }
            
        do {
            let db = try Database(inMemory: ProcessInfo.isOnPreview)
            
            if USE_MOCKUP_DATA {
                let initializer = MockupDataGenerator(db: db)
                try! initializer.writeMockedData()
            }
            
            let priceDataProvidersMap: PriceDataProvidersMap = .from([
                CachedPriceDataProvider(provider: BinancePriceDataProvider()),
                CachedPriceDataProvider(provider: KuCoinPriceDataProvider()),
                CachedPriceDataProvider(provider: FinnhubFinanceDataProvider()),
                CachedPriceDataProvider(provider: BankierPriceDataProvider())
            ])
            
            let currencyConverter: CurrencyConverterType = USE_MOCKUP_DATA
                ? MockedCurrencyConverter(priceDataProviders: priceDataProvidersMap)
                : CachedCurrencyConverter(currencyConverter: FCACurrencyConverter(priceDataProviders: priceDataProvidersMap), cacheDuration: .h1)
            
            let configStore = ConfigStore(db: db)
            let assetsStore = AssetsStore(db: db)
            let snapshotsStore = SnapshotsStore(db: db)

            let snapshotsStateTracker = SnapshotsStateTracker()
            
            let configManager = ConfigManager(
                configStore: configStore,
                snapshotsStateTracker: snapshotsStateTracker
            )
            
            let assetsManager = AssetsManager(
                assetsStore: assetsStore,
                snapshotsStateTracker: snapshotsStateTracker,
                priceDataProviders: priceDataProvidersMap
            )
            
            let snapshotGenerator = SnapshotGenerator(
                configManager: configManager,
                currencyConverter: currencyConverter,
                priceDataProviders: priceDataProvidersMap
            )
            
            let snapshotsManager = SnapshotsManager(
                assetsStore: assetsStore,
                snapshotsStore: snapshotsStore,
                snapshotsStateTracker: snapshotsStateTracker,
                configManager: configManager,
                generator: snapshotGenerator
            )
            
            self.services = Services(
                snapshotsStateTracker: snapshotsStateTracker,
                snapshotsManager: snapshotsManager,
                assetsManager: assetsManager,
                configManager: configManager,
                fcaCurrencyConverter: currencyConverter
            )
        
            Task { [self] in
                guard let config = try await configManager.snapshotsConfig else {
                    self.appInfo.appState = .setup
                    return
                }
                self.viewSettings.supportedCurrencies = config.supportedCurrencies
                self.viewSettings.load()
                self.services.snapshotsStateTracker.track(snapshotsInterval: config.interval)
                self.appInfo.appState = .ready
            }
        } catch let e {
            appInfo.appState = .error(e)
        }
    }

    var body: some Scene {        
        WindowGroup {
            switch appInfo.appState {
                case .setup:
                    SetupView(
                        viewModel: SetupViewModel(
                            configManager: services.configManager,
                            fcaCurrencyConverter: services.fcaCurrencyConverter
                        )
                    )
                    .environment(self.appInfo)
                    .environment(self.services)
                    .environment(self.viewSettings)
                case .ready:
                    MainView()
                    .environment(self.appInfo)
                    .environment(self.services)
                    .environment(self.viewSettings)
                case .loading:
                    LoadingScreen()
                case .error(let error):
                    ErrorScreen(error: error)
            }
        }
    }
}
