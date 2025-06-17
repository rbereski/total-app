//
//  DataProviderError.swift
//  TotalApp
//
//  Created by Rafal Bereski on 12/05/2025.
//

import Foundation

public enum DataProviderError: LocalizedError {
    case missingAPIKey(provider: String)
    case incorrectAPIKey(provider: String)
    case invalidSymbol(provider: String, symbol: String)
    case requestError(provider: String, message: String)
    
    public var errorDescription: String? {
        switch self {
            case .missingAPIKey(let provider): return "The API key for \(provider) is missing."
            case .incorrectAPIKey(let provider): return "The API key for \(provider) is incorrect."
            case .invalidSymbol(let provider, let symbol): return "The symbol \(symbol) was not recognized by \(provider) price data provider."
            case .requestError(let provider, let message): return "\(message) (from provider: \(provider))"
        }
    }
    
    public var failureReason: String? {
        return "Data Provider Error"
    }
    
    public var recoverySuggestion: String? {
        switch self {
            case .missingAPIKey, .incorrectAPIKey: return "Go to Settings -> API Keys and add correct API key."
            case .invalidSymbol: return "Check if the symbol is correct and try again."
            case .requestError: return "Try again later."
        }
    }

}
