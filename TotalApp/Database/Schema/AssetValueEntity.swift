//
//  AssetValueEntity.swift
//  TotalApp
//
//  Created by Rafal Bereski on 03/05/2025.
//

import Foundation
import SwiftData

@Model
public class AssetValueEntity {
    public private(set) var createdTs: Int
    public private(set) var intervalTs: Int
    public private(set) var assetId: UUID
    public private(set) var assetType: AssetType
    public private(set) var unitPrice: Double
    public private(set) var valueBtc: Double
    public private(set) var valueUsd: Double
    public private(set) var valueCurr1: Double
    public private(set) var valueCurr2: Double
    public private(set) var valueCurr3: Double
    
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
    }
    
    public convenience init(from entry: AssetValue) {
        self.init(
            createdTs: entry.createdTs,
            intervalTs: entry.intervalTs,
            assetId: entry.assetId,
            assetType: entry.assetType,
            unitPrice: entry.unitPrice,
            valueBtc: entry.valueBtc,
            valueUsd: entry.valueUsd,
            valueCurr1: entry.valueCurr1,
            valueCurr2: entry.valueCurr2,
            valueCurr3: entry.valueCurr3
        )
    }
}
