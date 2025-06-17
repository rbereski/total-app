//  ChartUnavailableView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 11/06/2025.
//

import SwiftUI

struct ChartUnavailableView: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            ContentUnavailableView {
                Label("Not enough data to render the chart.", systemImage: "chart.xyaxis.line")
                    .font(.caption)
                    .foregroundStyle(.secondary.opacity(0.75))
            }
        }
    }
}



