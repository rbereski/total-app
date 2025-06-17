//
//  AssetTypeExtensions.swift
//  TotalApp
//
//  Created by Rafal Bereski on 28/05/2025.
//

import SwiftUI

public extension AssetType {
    var color: Color {
        switch self {
            case .cash: return .orange
            case .crypto: return .blue
            case .stock: return .green
            case .commodity: return .indigo
            case .real: return .red
            case .other: return .cyan
        }
    }
    
    var sortOrder: Int {
        switch self {
            case .cash: return 0
            case .crypto: return 1
            case .stock: return 2
            case .commodity: return 3
            case .real: return 4
            case .other: return 5
        }
    }
}
