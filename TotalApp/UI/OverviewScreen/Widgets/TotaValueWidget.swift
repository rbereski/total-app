//
//  TotaValueWidget.swift
//  TotalApp
//
//  Created by Rafal Bereski on 06/06/2025.
//

import SwiftUI

struct TotaValueWidget: View {
    var snapshotOverview: SnapshotOverview
    @Binding var selectedCurrency: Currency
    var snapshotState: SnapshotState
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 2) {
            if let formattedValue = snapshotOverview.formattedPortolioValues[selectedCurrency] {
                Text("Total Portfolio Value")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formattedValue)
                    .font(.title)
                    .bold()
                SnapshotStateLabel(state: snapshotState)
            } else {
                Text("No snapshot available")
                    .font(.body)
                    .foregroundStyle(.secondary.opacity(0.75))
            }

        }
    }
}
