//
//  CategoryValueEntity.swift
//  TotalApp
//
//  Created by Rafal Bereski on 03/05/2025.
//

import SwiftData

@Model
public class CategoryValueEntity {
    public private(set) var createdTs: Int
    public private(set) var intervalTs: Int
    public private(set) var _assetType: Int
    
    public var assetType: AssetType {
        .init(rawValue: _assetType) ?? .cash
    }
    
    public var valueBtc: Double
    public var valueUsd: Double
    public var valueCurr1: Double
    public var valueCurr2: Double
    public var valueCurr3: Double
    
    public init(
        createdTs: Timestamp,
        intervalTs: Timestamp,
        assetType: AssetType,
        valueBtc: Double,
        valueUsd: Double,
        valueCurr1: Double,
        valueCurr2: Double,
        valueCurr3: Double
    ) {
        self.createdTs = createdTs
        self.intervalTs = intervalTs
        self._assetType = assetType.rawValue
        self.valueBtc = valueBtc
        self.valueUsd = valueUsd
        self.valueCurr1 = valueCurr1
        self.valueCurr2 = valueCurr2
        self.valueCurr3 = valueCurr3
    }
    
    public convenience init(from entry: CategoryValue) {
        self.init(
            createdTs: entry.createdTs,
            intervalTs: entry.intervalTs,
            assetType: entry.assetType,
            valueBtc: entry.valueBtc,
            valueUsd: entry.valueUsd,
            valueCurr1: entry.valueCurr1,
            valueCurr2: entry.valueCurr2,
            valueCurr3: entry.valueCurr3
        )
    }
}
