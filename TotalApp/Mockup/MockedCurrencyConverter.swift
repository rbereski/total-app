//
//  MockedCurrencyConverter.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation

public class MockedCurrencyConverter: CurrencyConverterType {
    public var btcPriceProviderId: PriceDataProviderID = .defaultPriceProvider(forCategory: .crypto)
    public var apiKey: String = ""
    private let priceDataProviders: PriceDataProvidersMap
    
    var rates: [Currency : Double] = [
        .aud: 1.5727802327,
        .bgn: 1.8652901997,
        .brl: 5.7288709434,
        .cad: 1.4223702126,
        .chf: 0.8972701058,
        .cny: 7.2431313093,
        .czk: 23.9367834009,
        .dkk: 7.1293511961,
        .eur: 0.9555101718,
        .gbp: 0.7913001534,
        .hkd: 7.7682111961,
        .hrk: 6.6987111294,
        .huf: 385.1585349701,
        .idr: 16277.667507002,
        .ils: 3.5691105976,
        .inr: 86.5329541394,
        .isk: 139.0844909904,
        .jpy: 149.283502886,
        .krw: 1430.5362727066,
        .mxn: 20.422632077,
        .myr: 4.4162405664,
        .nok: 11.1414414051,
        .nzd: 1.7414803175,
        .php: 57.8716600591,
        .pln: 3.9736107651,
        .ron: 4.7564007487,
        .rub: 88.466085396,
        .sek: 10.6404711551,
        .sgd: 1.335020169,
        .thb: 33.5284758003,
        .try: 36.4176541924,
        .usd: 1,
        .zar: 18.2972921177
    ]
    
    public init (priceDataProviders: PriceDataProvidersMap) {
        self.priceDataProviders = priceDataProviders
    }
    
    public func configure(with configManager: ConfigManager) async throws(CurrencyConverterError) { /* Empty */ }
    public func getRates() throws(CurrencyConverterError) -> ExchangeRates { rates }
    public func set(rates: ExchangeRates) { /* Empty */ }
    
    public func updateRatesSync() {
        guard
            let btcPriceProvider = priceDataProviders[btcPriceProviderId],
            let mockedBtcPriceProvider = btcPriceProvider as? MockedPriceDataProviderType
            else { return }
        rates[.btc] = 1.0 / mockedBtcPriceProvider.fetchPriceSync(symbol: Currency.btc.symbol).price
    }
    
    public func updateRates() async throws(CurrencyConverterError) {
        guard let btcPriceProvider = priceDataProviders[btcPriceProviderId] else {
            throw .missingBTCPriceProvider
        }
        
        do {
            let btcPrice = try await btcPriceProvider.fetchPrice(symbol: Currency.btc.symbol).price
            rates[.btc] = 1.0 / btcPrice
        } catch let error {
            throw .failedToFetchBTCPrice(error)
        }
    }
    
    public func convert(_ amount: Double, from: Currency, to: Currency) throws(CurrencyConverterError) -> Double {
        guard from != to else { return amount }
        guard !rates.keys.isEmpty else { throw CurrencyConverterError.uninitializedExchangeRates }
        let usdValue = try convertToUSD(amount: amount, currency: from)
        let dstValue = try convertFromUSD(amount: usdValue, currency: to)
        return dstValue
    }
    
    private func convertToUSD(amount: Double, currency: Currency) throws(CurrencyConverterError) -> Double {
        guard let rate = rates[currency] else { throw CurrencyConverterError.unsupportedCurrencySymbol }
        return amount / rate
    }
    
    private func convertFromUSD(amount: Double, currency: Currency) throws(CurrencyConverterError) -> Double {
        guard let rate = rates[currency] else { throw CurrencyConverterError.unsupportedCurrencySymbol }
        return amount * rate
    }
}
