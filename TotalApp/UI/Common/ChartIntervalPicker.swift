//
//  ChartIntervalPicker.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/06/2025.
//

import SwiftUI

struct ChartIntervalPicker: View {
    private let intervals: [Interval] = Consts.historyChartIntervals
    private var chartModel: HistoryChartModel
    
    init(chartModel: HistoryChartModel) {
        self.chartModel = chartModel
    }
    
    struct IntervalButton: View {
        var interval: Interval
        var selected: Bool
        var action: (Interval) -> Void
        var body: some View {
            Button(interval.symbol, action: { action(interval) })
                .buttonStyle(.plain)
                .controlSize(.small)
                .font(.caption)
                .bold()
                .foregroundStyle(selected ? .primary : .secondary)
                .padding(EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6))
                .background(selected ? .selectedIntervalButtonBkg : .clear)
                .cornerRadius(8)
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(intervals, id: \.self) { interval in
                IntervalButton(
                    interval: interval,
                    selected: interval == chartModel.chartInterval,
                    action: { interval in Task { await chartModel.set(chartInterval: interval) } }
                )
            }
        }
    }
}
