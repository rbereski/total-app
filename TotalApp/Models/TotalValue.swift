//
//  TotalValueLogEntry.swift
//  TotalApp
//
//  Created by Rafal Bereski on 13/04/2025.
//

import SwiftData

public class TotalValue: MutableValueLogEntry {
    public private(set) var createdTs: Timestamp
    public private(set) var intervalTs: Timestamp
    public var valueBtc: Double
    public var valueUsd: Double
    public var valueCurr1: Double
    public var valueCurr2: Double
    public var valueCurr3: Double
    public var values: [Double] = []
    
    public init(
        createdTs: Timestamp,
        intervalTs: Timestamp,
        valueBtc: Double,
        valueUsd: Double,
        valueCurr1: Double,
        valueCurr2: Double,
        valueCurr3: Double
    ) {
        self.createdTs = createdTs
        self.intervalTs = intervalTs
        self.valueBtc =  valueBtc
        self.valueUsd = valueUsd
        self.valueCurr1 = valueCurr1
        self.valueCurr2 = valueCurr2
        self.valueCurr3 = valueCurr3
        updateValuesArray()
    }
    
    public convenience init(createdTs: Timestamp, intervalTs: Timestamp) {
        self.init(
            createdTs: createdTs,
            intervalTs: intervalTs,
            valueBtc: 0,
            valueUsd: 0,
            valueCurr1: 0,
            valueCurr2: 0,
            valueCurr3: 0
        )
    }
    
    public convenience init(from entity: TotalValueEntity) {
        self.init(
            createdTs: entity.createdTs,
            intervalTs: entity.intervalTs,
            valueBtc: entity.valueBtc,
            valueUsd: entity.valueUsd,
            valueCurr1: entity.valueCurr1,
            valueCurr2: entity.valueCurr2,
            valueCurr3: entity.valueCurr3
        )
    }
}
