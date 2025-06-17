//
//  SetupViewModel.swift
//  TotalApp
//
//  Created by Rafal Bereski on 21/05/2025.
//

import Observation

@MainActor
@Observable
public class SetupViewModel {
    private let configManager: ConfigManager
    private let fcaCurrencyConverter: CurrencyConverterType
    public let availableBTCPriceProviders = PriceDataProviderID.btcPriceProviders
    public var requiredCurrencies: [Currency] = Consts.requiredCurrencies
    public var optionalCurrencies: [Currency] = []
    public var snapshotsInterval: Interval = Consts.defaultSnapshotsInterval
    public var btcPriceProvider: PriceDataProviderID = Consts.defaultBtcPriceProvider
    public var freeCurrencyApiKey: String?
    
    public init(configManager: ConfigManager, fcaCurrencyConverter: CurrencyConverterType) {
        self.configManager = configManager
        self.fcaCurrencyConverter = fcaCurrencyConverter
    }
    
    public func saveConfiguration() async throws {
        try await configManager.save(snapshotsConfig: .init(currencies: optionalCurrencies, interval: snapshotsInterval, btcPriceProvider: btcPriceProvider))
        
        let fcApiKey = APIKey(
            id: APIProvider.freeCurrencyApi.defaultKeyId,
            key: freeCurrencyApiKey ?? "",
            provider: .freeCurrencyApi
        )
        
        try await configManager.save(apiKey:fcApiKey, overwriteExisting: true)
    }

    public func checkFreeCurrencyAPIKey() async -> Bool {
        guard let apiKey = freeCurrencyApiKey else { return false }
        fcaCurrencyConverter.apiKey = apiKey
        do {
            try await fcaCurrencyConverter.updateRates()
            return true
        } catch {
            return false
        }
    }
}
