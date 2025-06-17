//
//  Theme.swift
//  TotalApp
//
//  Created by Rafal Bereski on 24/05/2025.
//

import SwiftUI

public enum Theme: String, Codable, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    public static var all : [Theme] {
        [.system, .light, .dark]
    }
    
    public var id: String {
        rawValue
    }
    
    public var name: String {
        rawValue
    }
    
    public var colorScheme: ColorScheme? {
        switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
        }
    }
}
