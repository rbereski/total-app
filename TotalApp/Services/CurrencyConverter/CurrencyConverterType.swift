//
//  CurrencyConverterType.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

public protocol CurrencyConverterType: AnyObject {
    typealias ExchangeRates = [Currency: Double]
    var apiKey: String { get set }
    var btcPriceProviderId: PriceDataProviderID { get set }
    func configure(with configManager: ConfigManager) async throws(CurrencyConverterError)
    func convert(_ amount: Double, from: Currency, to: Currency) throws(CurrencyConverterError) -> Double
    func getRates() throws(CurrencyConverterError) -> ExchangeRates
    func set(rates: ExchangeRates)
    func updateRates() async throws(CurrencyConverterError)
}
