//
//  Timestamp.swift
//  TotalApp
//
//  Created by Rafal Bereski on 15/04/2025.
//

import Foundation

public typealias Timestamp = Int

public extension Timestamp {
    static var current: Timestamp {
        Timestamp(Date().timeIntervalSince1970)
    }
    
    func toDate() -> Date {
        Date(timeIntervalSince1970: Double(self))
    }
}
