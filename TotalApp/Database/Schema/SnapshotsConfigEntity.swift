//
//  SnapshotsConfigEntity.swift
//  TotalApp
//
//  Created by Rafal Bereski on 20/04/2025.
//

import Foundation
import SwiftData

@Model
public class SnapshotsConfigEntity {
    public var currency1: Currency?
    public var currency2: Currency?
    public var currency3: Currency?
    public var snapshotInterval: Interval
    public var btcPriceProviderId: String?
    
    public init(
        currency1: Currency? = nil,
        currency2: Currency? = nil,
        currency3: Currency? = nil,
        snapshotInterval: Interval,
        btcPriceProviderId: String? = nil
    ) {
        self.currency1 = currency1
        self.currency2 = currency2
        self.currency3 = currency3
        self.snapshotInterval = snapshotInterval
        self.btcPriceProviderId = btcPriceProviderId
    }
    
    public convenience init(from config: SnapshotsConfig) {
        self.init(
            currency1: config.currency1,
            currency2: config.currency2,
            currency3: config.currency3,
            snapshotInterval: config.interval,
            btcPriceProviderId: config.btcPriceProvider.id
        )
    }
    
    public var currencies: [Currency] {
        [currency1, currency2, currency3]
            .compactMap { $0 }
    }
}
