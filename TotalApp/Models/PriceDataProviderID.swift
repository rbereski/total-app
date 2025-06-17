//
//  PriceDataProviderID.swift
//  TotalApp
//
//  Created by Rafal Bereski on 12/05/2025.
//

public enum PriceDataProviderID: String, CaseIterable, RawRepresentable, Equatable, Identifiable {
    case fixedPrice = "FIXED-PRICE"
    case binance = "BINANCE-SPOT-API"
    case kucoin = "KUCOIN-SPOT-API"
    case finnhub = "FINNHUB-API"
    case bankier = "BANKIER-PL-WEB"
    
    public var id: String {
        rawValue
    }
    
    var providerName: String {
        switch self {
            case .fixedPrice: return "Fixed Price"
            case .binance: return "Binance"
            case .kucoin: return "KuCoin"
            case .finnhub: return "Finnhub"
            case .bankier: return "Bankier"
        }
    }
    
    var supportedAssets: [AssetType] {
        switch self {
            case .binance, .kucoin: return [.crypto]
            case .finnhub, .bankier: return [.stock, .commodity, .real, .other]
            case .fixedPrice: return [.crypto, .stock, .commodity, .real, .other]
        }
    }
}

public extension PriceDataProviderID {
    static func parse(_ identifier: String?, defaultProvider: PriceDataProviderID) -> PriceDataProviderID {
        guard let identifier = identifier, !identifier.isEmpty else { return .fixedPrice }
        return PriceDataProviderID(rawValue: identifier) ?? .fixedPrice
    }
    
    static func parse(_ identifier: String?) throws -> PriceDataProviderID? {
        guard let identifier = identifier, !identifier.isEmpty else { return .fixedPrice }
        guard let provider = PriceDataProviderID(rawValue: identifier) else { return nil }
        return provider
    }
    
    static func defaultPriceProvider(forCategory category: AssetType) -> PriceDataProviderID {
        switch category {
            case .crypto: return .binance
            case .stock, .commodity, .other: return .finnhub
            default: return .fixedPrice
        }
    }
    
    static var btcPriceProviders: [PriceDataProviderID] {
        Self.allCases.filter { $0 != .fixedPrice && $0.supportedAssets.contains(.crypto) }
    }
}
