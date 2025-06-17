//
//  AssetType.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

public enum AssetType : Int, Codable, CaseIterable, Identifiable, Sendable {
    case cash = 0
    case crypto = 1
    case stock = 2
    case commodity = 3
    case real = 4
    case other = 5
    
    public var id: Self {
        self
    }

    static let assetsVithValue: [AssetType] = [.cash, .crypto, .stock, .commodity, .real, .other]
    
    public var title: String {
        switch self {
            case .cash: return "Cash / Bank Account"
            case .crypto: return "Crypto"
            case .stock: return "Stock"
            case .commodity: return "Commodity"
            case .real: return "Real Asset"
            case .other: return "Other"
        }
    }
    
    public var legendLabel: String {
        switch self {
            case .cash: return "Cash"
            case .crypto: return "Crypto"
            case .stock: return "Stocks"
            case .commodity: return "Commodities"
            case .real: return "Real"
            case .other: return "Other"
        }
    }
    
    public var categoryShortTitle: String {
        switch self {
            case .cash: return "Cash"
            case .crypto: return "Crypto"
            case .stock: return "Stocks"
            case .commodity: return "Commodities"
            case .real: return "Real Assets"
            case .other: return "Other"
        }
    }
    
    public var categoryTitle: String {
        switch self {
            case .cash: return "Cash / Bank Accounts"
            case .crypto: return "Cryptocurrencies"
            case .stock: return "Stocks"
            case .commodity: return "Commodities"
            case .real: return "Real Assets"
            case .other: return "Other"
        }
    }
    
    public var iconName: String {
        return "chart.xyaxis.line"
    }
}
