//
//  MockedPriceDataProviderType.swift
//  TotalApp
//
//  Created by Rafal Bereski on 25/05/2025.
//

public protocol MockedPriceDataProviderType: PriceDataProviderType {
    var initialTs: Timestamp { get set }
    var currentTs: Timestamp { get set }
    func fetchPriceSync(symbol: String) -> AssetPrice
}
