//
//  SnapshotsStateTracker.swift
//  TotalApp
//
//  Created by Rafal Bereski on 09/06/2025.
//

import Foundation
import Observation

@MainActor
@Observable
public class SnapshotsStateTracker {
    @ObservationIgnored private var lastSnapshotTs: Timestamp = 0
    @ObservationIgnored private var lastAssetModTs: Timestamp = 0
    @ObservationIgnored private var snapshotsInterval: Interval = .h24
    @ObservationIgnored private var timer: Timer?
    public private(set) var state: SnapshotState = .none

    public init() {
        startTimer()
    }
    
    public func track(latestSnapshot: Snapshot) {
        lastSnapshotTs = latestSnapshot.totalValue.createdTs
        updateState()
    }
    
    public func track(assetModificationTs timestamp: Timestamp) {
        lastAssetModTs = max(lastAssetModTs, timestamp)
        updateState()
    }
    
    public func track(snapshotsInterval: Interval) {
        self.snapshotsInterval = snapshotsInterval
        updateState()
    }
    
    private func updateState() {
        if lastAssetModTs <=  0 {
            state = .none
            return
        }
        
        if (lastAssetModTs > lastSnapshotTs) {
            state = .invalidated
            return
        }
        
        let currentTs = Timestamp.current
        let prevTimeFrameStartTs = snapshotsInterval.relativeIntervalStartTimestamp(ts: currentTs, distance: -1)
        let currentTimeFrameStartTs = snapshotsInterval.startTimestamp(ts: currentTs)
        
        if (lastSnapshotTs < prevTimeFrameStartTs) {
            state = .outdated(timeFrame: snapshotsInterval)
            return
        }
        
        
        if (lastSnapshotTs < currentTimeFrameStartTs && currentTs >= currentTimeFrameStartTs + snapshotsInterval.duration / 2) {
            state = .outdated(timeFrame: snapshotsInterval)
            return
        }
        
        self.state = .upToDate(timestamp: lastSnapshotTs)
    }
    
    private func startTimer() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(Interval.m5.duration), repeats: true) { [weak self] timer in
            Task { await self?.updateState() }
        }
    }
}
