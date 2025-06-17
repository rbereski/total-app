//
//  ColorPresets.swift
//  TotalApp
//
//  Created by Rafal Bereski on 27/05/2025.
//

import SwiftUI

public enum ChartColors {
    public static let all: [Color] = [.blue, .orange, .green, .purple, .red, .yellow, .brown, .pink, .teal, .indigo, .mint, .gray, .black]
    
    public static func color(forIndex index: Int) -> Color {
        all[index % all.count]
    }
}
