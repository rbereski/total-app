//
//  PriceDataProvidersMap.swift
//  TotalApp
//
//  Created by Rafal Bereski on 19/05/2025.
//

public typealias PriceDataProvidersMap = [PriceDataProviderID : PriceDataProviderType]

public extension PriceDataProvidersMap {
    static func from(_ providers: [PriceDataProviderType]) -> Self {
        return Dictionary(uniqueKeysWithValues: providers.map({ ($0.id, $0)}))
    }
}
