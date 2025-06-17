//
//  PortfolioCategoriesHistoryWidget.swift
//  TotalApp
//
//  Created by Rafal Bereski on 28/05/2025.
//

import SwiftUI
import Charts

struct CategoriesHistoryWidget: View {
    @Environment(ViewSettings.self) private var viewSettings: ViewSettings
    private let categories: [AssetType] = AssetType.assetsVithValue
    private var chartModel: CategoriesHistory
    
    init(chartModel: CategoriesHistory) {
        self.chartModel = chartModel
    }
    
    var body: some View {
        if chartModel.hasEnoughData {
            VStack(alignment: .leading, spacing: 12) {
                Chart {
                    ForEach(categories, id: \.id) { category in
                        LinePlot(
                            chartModel.values[category]![viewSettings.selectedCurrency] ?? [],
                            x: .value("Date", \.date),
                            y: .value("Value", \.value),
                            series: .value("Asset", category.legendLabel)
                        )
                        .foregroundStyle(category.color)
                    }
                }
                .chartForegroundStyleScale(
                    domain: AssetType.assetsVithValue.map { $0.legendLabel },
                    range: AssetType.assetsVithValue.map { $0.color }
                )
                .chartLegend(position: .bottom, alignment: .center, spacing: 8, content: {
                    AssetCategoriesLegend(categories: categories)
                })
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
                .frame(minHeight: 160)
            }
            ChartIntervalPicker(chartModel: chartModel)
        } else {
            ChartUnavailableView()
        }
    }
}

struct AssetCategoriesLegend: View {
    let legendLines: [[AssetType]]
    
    init(categories: [AssetType], lineLength: Int = 6) {
        self.legendLines = AssetType.assetsVithValue.chunked(into: lineLength)
    }
    
    var body: some View {
        VStack(alignment: .center) {
            ForEach(legendLines, id: \.self) { categories in
                HStack(spacing: 8) {
                    ForEach(categories) { category in
                        HStack(spacing: 3) {
                            Circle()
                                .fill(category.color)
                                .frame(width: 5, height: 5)
                            Text(category.legendLabel)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
    }
}

