//
//  APIProvider.swift
//  TotalApp
//
//  Created by Rafal Bereski on 16/06/2025.
//

public enum APIProvider: String, RawRepresentable, Identifiable, CaseIterable {
    case freeCurrencyApi = "FREE-CURRENCY-API"
    case finnhub = "FINNHUB"
    case unspecified = "UNKNOWN"
    
    public var id: String {
        rawValue
    }
    
    public var type: APIProviderType {
        switch self {
            case .freeCurrencyApi: return .currencyConverter
            case .finnhub: return .priceDataSource
            case .unspecified: return .unspecified
        }
    }
    
    public var name: String {
        switch self {
            case .freeCurrencyApi: return "Free Currency API"
            case .finnhub: return "Finnhub"
            case .unspecified: return "Unspecified"
        }
    }
    
    public var defaultKeyId: String {
        switch self {
            case .freeCurrencyApi: return "FREE-CURRENCY-API-KEY"
            case .finnhub: return "FINNHUB-API-KEY"
            case .unspecified: return ""
        }
    }
}

public enum APIProviderType: Int, Identifiable, CaseIterable, Equatable {
    case currencyConverter = 0
    case priceDataSource = 1
    case unspecified = 3
    
    public var id: Int {
        rawValue
    }
    
    public var categoryTitle: String {
        switch self {
            case .currencyConverter: return "Currency Converters"
            case .priceDataSource: return "Price Data Sources"
            case .unspecified: return "Other Keys"
        }
    }
}
