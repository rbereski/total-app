//
//  ErrorScreen.swift
//  TotalApp
//
//  Created by Rafal Bereski on 13/06/2025.
//

import SwiftUI
import ActivityIndicatorView

struct ErrorScreen: View {
    var error: DataStoreError
    
    var body: some View {
        ZStack {
            AppBackground()
            VStack {
                ContentUnavailableView(
                    "Something went wrong",
                    systemImage: "x.circle",
                    description: Text(error.localizedDescription)
                )
            }
        }
    }
}
