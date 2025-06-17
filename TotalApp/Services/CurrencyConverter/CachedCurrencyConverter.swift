//
//  CachedCurrencyConverter.swift
//  TotalApp
//
//  Created by Rafal Bereski on 12/04/2025.
//

public class CachedCurrencyConverter: CurrencyConverterType {
    private let currencyConverter: CurrencyConverterType
    private let cacheDuration: Interval
    private var cachedRates: ExchangeRates?
    private var cachedRatesTs: Timestamp = 0
    
    public init (currencyConverter: CurrencyConverterType, cacheDuration: Interval) {
        self.currencyConverter = currencyConverter
        self.cacheDuration = cacheDuration
    }

    public var btcPriceProviderId: PriceDataProviderID {
        get { currencyConverter.btcPriceProviderId }
        set(newValue) { currencyConverter.btcPriceProviderId = newValue  }
    }
    
    public var apiKey: String {
        get { currencyConverter.apiKey }
        set(newValue) { currencyConverter.apiKey = newValue  }
    }
    
    public func configure(with configManager: ConfigManager) async throws(CurrencyConverterError) {
        try await currencyConverter.configure(with: configManager)
    }

    public func getRates() throws(CurrencyConverterError) -> ExchangeRates {
        guard let rates = cachedRates else { throw .uninitializedExchangeRates }
        return rates
    }
    
    public func set(rates: ExchangeRates) {
        cachedRatesTs = Timestamp.current
        cachedRates = rates
        currencyConverter.set(rates: rates)
    }
    
    public func updateRates() async throws(CurrencyConverterError) {
        if cachedRates == nil || Timestamp.current - cachedRatesTs >= cacheDuration.duration {
            try await currencyConverter.updateRates()
            cachedRates = try currencyConverter.getRates()
            cachedRatesTs = Timestamp.current
        } else {
            currencyConverter.set(rates: cachedRates!)
        }
    }
    
    public func convert(_ amount: Double, from: Currency, to: Currency) throws(CurrencyConverterError) -> Double {
        try self.currencyConverter.convert(amount, from: from, to: to)
    }
}
    
