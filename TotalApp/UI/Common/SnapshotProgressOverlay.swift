//
//  SnapshotProgressOverlay.swift
//  TotalApp
//
//  Created by Rafal Bereski on 15/05/2025.
//

import SwiftUI
import ActivityIndicatorView

public struct SnapshotProgressOverlay: View {
    @State public var showIndicator: Bool = true
    public var body: some View {
        ZStack {
            Color.clear
            VStack {
                ActivityIndicatorView(isVisible: $showIndicator, type: .default(count: 8))
                    .frame(width: 64, height: 64)
                    .foregroundColor(.activityIndicator)
                    .padding(16)
                Text("Generating snapshot...")
                    .foregroundStyle(.primary)
                    .font(.body)
            }
            .padding(32)
            .background(.snapshotActivityIndicatorBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.5), radius: 16)
        }
    }
}

#Preview {
    SnapshotProgressOverlay()
}
