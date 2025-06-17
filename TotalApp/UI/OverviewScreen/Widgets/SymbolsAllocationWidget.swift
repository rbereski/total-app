//
//  SymbolsAllocationWidget.swift
//  TotalApp
//
//  Created by Rafal Bereski on 06/06/2025.
//

import SwiftUI
import Charts

struct SymbolsAllocationWidget: View {
    @Environment(ViewSettings.self) private var viewSettings: ViewSettings
    private var summary: [SnapshotOverview.SymbolSummary]
    
    init(summary: [SnapshotOverview.SymbolSummary]) {
        self.summary = summary
    }
    
    var body: some View {
        let formatters = NumberFormattersCache.shared
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(summary) { item in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(ChartColors.color(forIndex: item.colorIndex))
                                .frame(width: 8, height: 8)
                            Text(item.name)
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.secondary)
                            Text("(\(formatters.format(percentage: item.percentage)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 8) {
                            Text(formatters.format(price: item.value[viewSettings.selectedCurrency] ?? 0, currency: viewSettings.selectedCurrency))
                                .font(.caption)
                                .bold()
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            Chart(summary) { item in
                SectorMark(
                    angle: .value(Text(verbatim: item.name),item.value[.usd] ?? 0)
                )
                .foregroundStyle(ChartColors.color(forIndex: item.colorIndex))
            }
            .chartLegend(.hidden)
            .aspectRatio(1.4, contentMode: .fit)
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 140)
        }
    }
}
