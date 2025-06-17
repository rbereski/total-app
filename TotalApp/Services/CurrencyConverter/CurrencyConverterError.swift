//
//  CurrencyConverterError.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation

public enum CurrencyConverterError : LocalizedError {
    case missingAPIKey
    case incorrectAPIKey
    case incorrectCurrencyApiUrl
    case unsupportedCurrencySymbol
    case uninitializedExchangeRates
    case currencyAPIError(innerError: Error)
    case parseError
    case missingBTCPriceProvider
    case failedToFetchBTCPrice(DataProviderError)
    
    public var errorDescription: String? {
        switch self {
            case .missingAPIKey: return "Missing API key for the curreny converter."
            case .incorrectAPIKey: return "Incorrect API key for the curreny converter."
            case .incorrectCurrencyApiUrl: return "Incorrect currency API URL."
            case .unsupportedCurrencySymbol: return "Unsupported currency symbol."
            case .uninitializedExchangeRates: return "Currency exchange rates are not initialized."
            case .currencyAPIError(let innerError): return "Error while sending currency API request (details: \(innerError.localizedDescription))."
            case .parseError: return  "Failed to parse API response - invalid JSON format."
            case .missingBTCPriceProvider: return "Missing BTC price provider."
            case .failedToFetchBTCPrice(let innerError): return "Failed to fetch BTC price (details: \(innerError.failureReason ?? "None"))."
        }
    }
    
    public var failureReason: String? {
        "Currency Converter Error"
    }
    
    public var recoverySuggestion: String? {
        switch self {
            case .missingAPIKey, .incorrectAPIKey: return "Go to Settings -> API Keys and add correct API key."
            case .currencyAPIError, .parseError: return "Try again later."
            default: return nil
        }
    }
}
