//
//  RateLimitter.swift
//  TotalApp
//
//  Created by Rafal Bereski on 17/06/2025.
//

import Foundation

public actor RateLimiter {
    private let maxRequests: Int
    private let interval: TimeInterval
    private var requestTimestamps: [Date] = []
    
    public init(maxRequests: Int, interval: TimeInterval) {
        self.maxRequests = maxRequests
        self.interval = interval
    }
    
    public func waitIfNeed() async {
        let now = Date()
        requestTimestamps = requestTimestamps.filter {
            now.timeIntervalSince($0) < interval
        }
        
        if requestTimestamps.count < maxRequests {
            requestTimestamps.append(now)
            return
        }
        
        if let oldest = requestTimestamps.first {
            let waitTime = interval - now.timeIntervalSince(oldest)
            let nanoseconds = UInt64(waitTime * 1_000_000_000)
            try? await Task.sleep(nanoseconds: nanoseconds)
            await waitIfNeed()
        }
    }
}
