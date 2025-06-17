//
//  HistoryChartModel.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/06/2025.
//

import Observation

public protocol HistoryChartModel: Observation.Observable {
    @MainActor var chartInterval: Interval { get }
    @MainActor func set(chartInterval : Interval) async
}
