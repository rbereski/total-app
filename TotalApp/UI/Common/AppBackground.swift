//
//  AppBackground.swift
//  TotalApp
//
//  Created by Rafal Bereski on 08/05/2025.
//

import SwiftUI

struct AppBackground: View {
    var body: some View {
        ZStack {
            Color.appBackground
            LinearGradient(
                gradient: Gradient(colors: [.clear, .accentColor.opacity(0.1), .clear]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .edgesIgnoringSafeArea(.all)
    }
}
