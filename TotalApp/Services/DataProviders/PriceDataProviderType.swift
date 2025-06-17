//
//  PriceDataProviderType.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation

public protocol PriceDataProviderType {
    var id: PriceDataProviderID { get }
    func configure(with configManager: ConfigManager) async throws(DataProviderError)
    func fetchPrice(symbol: String) async throws(DataProviderError) -> AssetPrice
}

public extension PriceDataProviderType {
    var providerName: String {
        id.providerName
    }
    
    var supportedAssets: [AssetType] {
        id.supportedAssets
    }
    
    func requestError(_ msg: String) -> DataProviderError {
        .requestError(provider: providerName, message: msg)
    }
    
    func invalidSymbol(_ symbol: String) -> DataProviderError {
        .invalidSymbol(provider: providerName, symbol: symbol)
    }
}
