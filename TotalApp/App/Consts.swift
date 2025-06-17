//
//  Consts.swift
//  TotalApp
//
//  Created by Rafal Bereski on 23/05/2025.
//

public enum Consts {
    static let maxOptionalCurrencies: Int = 3
    static let requiredCurrencies: [Currency] = [.btc, .usd]
    static let defaultSnapshotsInterval: Interval = .h24
    static let snapshotIntervals: [Interval] = [.h6, .h8, .h12, .h24]
    static let defaultBtcPriceProvider: PriceDataProviderID = .binance
    static let historyChartIntervals: [Interval] = [.w1, .mth1, .mth3, .mth6, .y1, .y2]
    static let defaultHistoryChartInterval: Interval = .mth1
    
    static var maxSupportedCurrencies: Int {
        maxOptionalCurrencies + requiredCurrencies.count
    }
}
