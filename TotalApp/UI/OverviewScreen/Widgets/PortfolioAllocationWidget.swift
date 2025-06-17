//
//  PortfolioAllocationWidget.swift
//  TotalApp
//
//  Created by Rafal Bereski on 27/05/2025.
//

import SwiftUI
import Charts

struct PortfolioAllocationWidget: View {
    @Environment(ViewSettings.self) private var viewSettings: ViewSettings
    private var snapshotOverview: SnapshotOverview
    
    init(snapshotOverview: SnapshotOverview) {
        self.snapshotOverview = snapshotOverview
    }
    
    var body: some View {
        let formatters = NumberFormattersCache.shared
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(snapshotOverview.assetTypesAllocation) { category in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(category.id.color)
                                .frame(width: 8, height: 8)
                            Text(category.name.capitalized)
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.secondary)
                            Text("(\(formatters.format(percentage: category.percentage)))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 8) {
                            Text(formatters.format(price: category.value[viewSettings.selectedCurrency] ?? 0, currency: viewSettings.selectedCurrency))
                                .font(.caption)
                                .bold()
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            
            Chart(snapshotOverview.assetTypesAllocation) { category in
                SectorMark(
                    angle: .value(Text(verbatim: category.name.uppercased()), category.value[.usd] ?? 0),
                )
                .foregroundStyle(category.id.color)
            }
            .chartLegend(.hidden)
            .aspectRatio(1.4, contentMode: .fit)
            .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 140)
        }
    }
}
