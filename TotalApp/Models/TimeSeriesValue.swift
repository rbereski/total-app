import Foundation

public struct TimeSeriesValue: Identifiable {
    public let date: Date
    public let value: Double
    
    public var id: Int {
        Int(date.timeIntervalSince1970)
    }
}
