//
//  SnapshotButton.swift
//  TotalApp
//
//  Created by Rafal Bereski on 06/06/2025.
//

import SwiftUI

struct SnapshotButton : View {
    var action: () -> Void
    
    var body: some View {
        VStack {
            Button() {
                action();
            } label : {
                Label("New Snapshot", systemImage: "arrow.clockwise")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .cornerRadius(18)
            .padding(.vertical, 8)
        }
    }
}
