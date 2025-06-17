//
//  AssetPrice.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation

public struct AssetPrice : CustomStringConvertible {
    public var symbol: String
    public var price: Double
    public var currency: Currency
    public var timestamp: Int
    
    public init(symbol: String, price: Double, currency: Currency, timestamp: Int) {
        self.symbol = symbol
        self.price = price
        self.currency = currency
        self.timestamp = timestamp
    }
    
    public var description: String {
        return "[\(symbol): \(price) \(currency.rawValue)]"
    }
}
