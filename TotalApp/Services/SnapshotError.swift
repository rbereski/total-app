//
//  SnapshotError.swift
//  TotalApp
//
//  Created by Rafal Bereski on 15/04/2025.
//

import Foundation

public enum SnapshotError : LocalizedError {
    case databaseError(DataStoreError)
    case unknownPriceDataProvider(assetName: String)
    case unavailablePriceDataProvider(assetName: String)
    case missingSymbol(assetName: String)
    case unavailableSnapshotConfiguration
    case priceDataProviderError(DataProviderError)
    case currencyConversionError(CurrencyConverterError)
    case unknownError(Error)
    
    public var errorDescription: String? {
        switch self {
            case .databaseError(let error): return error.errorDescription
            case .unknownPriceDataProvider(let asset): return "Required price data provide for asset \"\(asset)\" not found."
            case .unavailablePriceDataProvider(let asset): return "Required price data provide for asset \"\(asset)\" not found."
            case .missingSymbol(let asset): return "Symbol not set for asset \"\(asset)\""
            case .unavailableSnapshotConfiguration: return "Error while reading snapshot configuration."
            case .priceDataProviderError(let error): return error.errorDescription
            case .currencyConversionError(let error): return error.errorDescription
            case .unknownError: return "Something went wrong."
        }
    }
    
    public var failureReason: String? {
        return "Snapshot Error"
    }
    
    public var recoverySuggestion: String? {
        switch self {
            case .priceDataProviderError(let error): return error.recoverySuggestion
            case .currencyConversionError(let error): return error.recoverySuggestion
            default: return nil
        }
    }
}
