//
//  TotalValueHistoryWidget.swift
//  TotalApp
//
//  Created by Rafal Bereski on 06/06/2025.
//

import SwiftUI
import Charts

struct TotalValueHistoryWidget: View {
    @Environment(ViewSettings.self) private var viewSettings: ViewSettings
    private var chartModel: TotalValueHistory
    
    init(chartModel: TotalValueHistory) {
        self.chartModel = chartModel
    }
    
    var body: some View {
        if chartModel.hasEnoughData {
            VStack(alignment: .leading, spacing: 12) {
                Chart(chartModel.values[viewSettings.selectedCurrency] ?? [], id: \.id ) { tsv in
                    AreaMark(
                        x: .value("Date", tsv.date),
                        y: .value("Value", tsv.value)
                    ).foregroundStyle(
                        .linearGradient(
                            colors: [.green.opacity(0.05), .green.opacity(0.6)],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    LineMark(
                        x: .value("Date", tsv.date),
                        y: .value("Value", tsv.value)
                    ).foregroundStyle(.green)
                }
                .chartYAxis {
                    AxisMarks(position: .trailing) { axisValue in
                        AxisGridLine()
                        if let yValue = axisValue.as(Double.self) {
                            AxisValueLabel() {
                                Text(NumberFormattersCache.shared.format(axisValue: yValue))
                            }
                        }
                    }
                }
                ChartIntervalPicker(chartModel: chartModel)
            }
        } else {
            ChartUnavailableView()
        }
    }
}
