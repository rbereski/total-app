//
//  ValueLogEntry.swift
//  TotalApp
//
//  Created by Rafal Bereski on 15/04/2025.
//

public protocol ValueLogEntry : AnyObject {
    var createdTs: Timestamp { get }
    var intervalTs: Timestamp { get }
    var valueBtc: Double { get }
    var valueUsd: Double { get }
    var valueCurr1: Double { get }
    var valueCurr2: Double { get }
    var valueCurr3: Double { get }
    var values: [Double] { get }
}

public protocol MutableValueLogEntry : ValueLogEntry {
    var createdTs: Timestamp { get }
    var intervalTs: Timestamp { get }
    var valueBtc: Double { get set }
    var valueUsd: Double { get set }
    var valueCurr1: Double { get set }
    var valueCurr2: Double { get set }
    var valueCurr3: Double { get set }
    var values: [Double] { get set }
}

public extension MutableValueLogEntry {
    func set(value: Double, currIdx: Int) {
        switch currIdx {
            case 0: valueBtc = value
            case 1: valueUsd = value
            case 2: valueCurr1 = value
            case 3: valueCurr2 = value
            case 4: valueCurr3 = value
            default: break
        }
        updateValuesArray()
    }
    
    
    func add(value: Double, currIdx: Int) {
        switch currIdx {
            case 0: valueBtc += value
            case 1: valueUsd += value
            case 2: valueCurr1 += value
            case 3: valueCurr2 += value
            case 4: valueCurr3 += value
            default: break
        }
        updateValuesArray()
    }
    
    func updateValuesArray() {
        values = [valueBtc, valueUsd, valueCurr1, valueCurr2, valueCurr3]
    }
}
