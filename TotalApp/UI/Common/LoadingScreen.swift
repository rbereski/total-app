//
//  LoadingScreen.swift
//  TotalApp
//
//  Created by Rafal Bereski on 24/05/2025.
//

import SwiftUI
import ActivityIndicatorView

struct LoadingScreen: View {
    @State var showAI: Bool = true
    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                ActivityIndicatorView(isVisible: $showAI, type: .default(count: 8))
                    .frame(width: 48, height: 48)
                    .foregroundColor(.activityIndicator)
                    .padding(8)
            }
        }
    }
}
