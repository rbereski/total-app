//
//  SnapshotState.swift
//  TotalApp
//
//  Created by Rafal Bereski on 11/06/2025.
//

public enum SnapshotState {
    case none
    case upToDate(timestamp: Timestamp)
    case outdated(timeFrame: Interval)
    case invalidated
}
