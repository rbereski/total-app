//
//  SnapshotsConfig.swift
//  TotalApp
//
//  Created by Rafal Bereski on 20/05/2025.
//

public class SnapshotsConfig {
    var currency1: Currency?
    var currency2: Currency?
    var currency3: Currency?
    var interval: Interval
    var btcPriceProvider: PriceDataProviderID
    
    var supportedCurrencies: [Currency] {
        Consts.requiredCurrencies + [currency1, currency2, currency3]
            .compactMap(\.self)
    }
    
    public init(currencies: [Currency], interval: Interval, btcPriceProvider: PriceDataProviderID) {
        self.currency1 = currencies.count > 0 ? currencies[0] : nil
        self.currency2 = currencies.count > 1 ? currencies[1] : nil
        self.currency3 = currencies.count > 2 ? currencies[2] : nil
        self.interval = interval
        self.btcPriceProvider = btcPriceProvider
    }
    
    public convenience init(from entity: SnapshotsConfigEntity) {
        self.init(
            currencies: entity.currencies,
            interval: entity.snapshotInterval,
            btcPriceProvider: entity.btcPriceProviderId
                .map { PriceDataProviderID(rawValue: $0) ?? PriceDataProviderID.defaultPriceProvider(forCategory: .crypto) }
                    ?? PriceDataProviderID.defaultPriceProvider(forCategory: .crypto)
        )
    }
}
