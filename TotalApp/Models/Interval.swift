//
//  Interval.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/05/2025.
//

public enum Interval: String, Codable, CaseIterable, Identifiable, Sendable {
    private static let DAY_DURATION = 86400
    
    case m1 = "1m"
    case m5 = "5m"
    case m15 = "15m"
    case h1 = "1H"
    case h6 = "6H"
    case h8 = "8H"
    case h12 = "12H"
    case h24 = "24H"
    case w1 = "1W"
    case mth1 = "1M"
    case mth3 = "3M"
    case mth6 = "6M"
    case y1 = "1Y"
    case y2 = "2Y"
    
    public var id: String {
        rawValue
    }
    
    public var symbol: String {
        rawValue
    }
    
    public var description: String {
        switch self {
            case .m1: "1 minute"
            case .m5: "5 minutes"
            case .m15: "15 minutes"
            case .h24: "24 hours"
            case .h12: "12 hours"
            case .h8: "8 hours"
            case .h6: "6 hours"
            case .h1: "1 hour"
            case .w1: "1 week"
            case .mth1: "1 month"
            case .mth3: "3 months"
            case .mth6: "6 months"
            case .y1: "1 year"
            case .y2: "2 years"
        }
    }
    
    public var duration: Int {
        switch self {
            case .m1: 60
            case .m5: 300
            case .m15: 900
            case .h1: 3600
            case .h6: Self.DAY_DURATION / 4
            case .h8: Self.DAY_DURATION / 3
            case .h12: Self.DAY_DURATION / 2
            case .h24: Self.DAY_DURATION
            case .w1: 7 * Self.DAY_DURATION
            // Estimations
            case .mth1: 31 * Self.DAY_DURATION
            case .mth3: 92 * Self.DAY_DURATION
            case .mth6: 183 * Self.DAY_DURATION
            case .y1: 366 * Self.DAY_DURATION
            case .y2: 731 * Self.DAY_DURATION
        }
    }
    
    public func startTimestamp(ts: Timestamp) -> Timestamp {
        (ts / duration) * duration
    }
    
    public func relativeIntervalStartTimestamp(ts: Timestamp, distance: Int) -> Timestamp {
        startTimestamp(ts: ts) + duration * distance
    }
}
