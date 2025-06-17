//
//  FCACurrencyConverter.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation

public class FCACurrencyConverter: CurrencyConverterType {
    private static let baseUrl = "https://api.freecurrencyapi.com/v1/latest"
    public var btcPriceProviderId: PriceDataProviderID = .defaultPriceProvider(forCategory: .crypto)
    public var apiKey: String = ""
    private let session: URLSession
    private var usdEchangeRates: ExchangeRates = [:]
    private let priceDataProviders: PriceDataProvidersMap
    
    public init(priceDataProviders: PriceDataProvidersMap) {
        self.priceDataProviders = priceDataProviders
        let config = URLSessionConfiguration.ephemeral
        config.httpShouldSetCookies = false
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: config)
    }
    
    public func configure(with configManager: ConfigManager) async throws(CurrencyConverterError) {
        guard let apiKey = await configManager.getAPIKey(forProvider: .freeCurrencyApi)?.key else {
            throw CurrencyConverterError.missingAPIKey
        }
        self.apiKey = apiKey
    }
    
    public func getRates() -> ExchangeRates {
        return usdEchangeRates
    }
    
    public func set(rates: ExchangeRates) {
        usdEchangeRates = rates
    }
    
    public func updateRates() async throws(CurrencyConverterError) {
        usdEchangeRates = try await loadExchangeRates(baseCurrency: .usd)
        
        guard let btcPriceProvider = priceDataProviders[btcPriceProviderId] else {
            throw .missingBTCPriceProvider
        }
        
        do {
            let btcPrice = try await btcPriceProvider.fetchPrice(symbol: Currency.btc.symbol).price
            usdEchangeRates[.btc] = 1.0 / btcPrice
        } catch let error {
            throw .failedToFetchBTCPrice(error)
        }
    }
    
    public func convert(_ amount: Double, from: Currency, to: Currency) throws(CurrencyConverterError) -> Double {
        guard from != to else { return amount }
        guard !usdEchangeRates.keys.isEmpty else { throw CurrencyConverterError.uninitializedExchangeRates }
        let usdValue = try convertToUSD(amount: amount, currency: from)
        let dstValue = try convertFromUSD(amount: usdValue, currency: to)
        return dstValue
    }
    
    private func convertToUSD(amount: Double, currency: Currency) throws(CurrencyConverterError) -> Double {
        guard let rate = usdEchangeRates[currency] else { throw CurrencyConverterError.unsupportedCurrencySymbol }
        return amount / rate
    }
    
    private func convertFromUSD(amount: Double, currency: Currency) throws(CurrencyConverterError) -> Double {
        guard let rate = usdEchangeRates[currency] else { throw CurrencyConverterError.unsupportedCurrencySymbol }
        return amount * rate
    }
    
    private func loadExchangeRates(baseCurrency: Currency) async throws(CurrencyConverterError) -> ExchangeRates {
        guard var components = URLComponents(string: Self.baseUrl) else { throw .incorrectCurrencyApiUrl }
        guard !apiKey.isEmpty else { throw .missingAPIKey }
        
        components.queryItems = [
            .init(name: "apikey", value: apiKey),
            .init(name: "base_currency", value: baseCurrency.symbol)
        ]
        
        guard let url = components.url else {
            throw .incorrectCurrencyApiUrl
        }
        
        let data = try await sendRequest(url: url)
        
        guard
            let jsonDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
            let ratesDict = jsonDict["data"] as? [String : Double]
        else {
            throw .parseError
        }
        
        var rates = ExchangeRates()
        for (symbol, rate) in ratesDict {
            guard let currency = Currency(rawValue: symbol) else { continue }
            rates[currency] = rate
        }
        
        return rates
    }
    
    private func sendRequest(url: URL) async throws(CurrencyConverterError) -> Data {
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await session.data(from: url)
        } catch let error {
            throw .currencyAPIError(innerError: error)
        }
        
        if (response as? HTTPURLResponse)?.statusCode == 401 {
            throw .incorrectAPIKey
        }
        
        return data
    }
}
