//
//  AssetValueLogEntry.swift
//  TotalApp
//
//  Created by Rafal Bereski on 13/04/2025.
//

import Foundation

public class AssetValue: MutableValueLogEntry {
    public private(set) var createdTs: Timestamp
    public private(set) var intervalTs: Timestamp
    public private(set) var assetId: UUID
    public private(set) var assetType: AssetType
    public private(set) var unitPrice: Double
    public var valueBtc: Double
    public var valueUsd: Double
    public var valueCurr1: Double
    public var valueCurr2: Double
    public var valueCurr3: Double
    public var values: [Double] = []
    
    public init(
        createdTs: Timestamp,
        intervalTs: Timestamp,
        assetId: UUID,
        assetType: AssetType,
        unitPrice: Double,
        valueBtc: Double,
        valueUsd: Double,
        valueCurr1: Double,
        valueCurr2: Double,
        valueCurr3: Double,
    ) {
        self.createdTs = createdTs
        self.intervalTs = intervalTs
        self.assetId = assetId
        self.assetType = assetType
        self.unitPrice = unitPrice
        self.valueBtc = valueBtc
        self.valueUsd = valueUsd
        self.valueCurr1 = valueCurr1
        self.valueCurr2 = valueCurr2
        self.valueCurr3 = valueCurr3
        updateValuesArray()
    }

    public convenience init(from entity: AssetValueEntity) {
        self.init(
            createdTs: entity.createdTs,
            intervalTs: entity.intervalTs,
            assetId: entity.assetId,
            assetType: entity.assetType,
            unitPrice: entity.unitPrice,
            valueBtc: entity.valueBtc,
            valueUsd: entity.valueUsd,
            valueCurr1: entity.valueCurr1,
            valueCurr2: entity.valueCurr2,
            valueCurr3: entity.valueCurr3
        )
    }
}
