//
//  Snapshot.swift
//  TotalApp
//
//  Created by Rafal Bereski on 15/04/2025.
//

import Foundation

public struct Snapshot {
    public let assetValues: [AssetValue]
    public let categoryValues: [CategoryValue]
    public let totalValue: TotalValue
    public let assetValuesMap: [UUID: AssetValue]
    
    public init(
        assetValues: [AssetValue],
        categoryValues: [CategoryValue],
        totalValue: TotalValue
    ) {
        self.assetValues = assetValues
        self.categoryValues = categoryValues
        self.totalValue = totalValue
        self.assetValuesMap = Dictionary(uniqueKeysWithValues: assetValues.map({($0.assetId, $0)}))
    }
}
