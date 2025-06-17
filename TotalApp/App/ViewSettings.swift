//
//  ViewSettings.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/05/2025.
//

import Foundation
import Observation

@MainActor
@Observable
public class ViewSettings {
    private enum Keys {
        static let theme = "view-settings-theme"
        static let selectedCurrency = "view-settings-currency"
        static let totalValueChartInterval = "total-value-chart-interval"
        static let categoriesValueChartInterval = "categories-value-chart-interval"
    }

    private let userDefaults: UserDefaults
    public var supportedCurrencies: [Currency] = Consts.requiredCurrencies
    public var selectedCurrency: Currency = ViewSettings.defaultCurrency
    public var theme: Theme = .system
    
    private static var defaultCurrency: Currency {
        Consts.requiredCurrencies.filter({ $0.isFiat }).first ?? .usd
    }

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
    }
    
    public func load() {
        self.theme = userDefaults.getEnum(Theme.self, forKey: Keys.theme, defaultValue: .system)
        self.selectedCurrency = userDefaults.getEnum(Currency.self, forKey: Keys.selectedCurrency, defaultValue: Self.defaultCurrency)
    }
    
    public func save() {
        userDefaults.set(theme.rawValue, forKey: Keys.theme)
        userDefaults.set(selectedCurrency.rawValue, forKey: Keys.selectedCurrency)
        userDefaults.synchronize()
    }
    
    public func reset() {
        [Keys.theme, Keys.selectedCurrency, Keys.totalValueChartInterval, Keys.categoriesValueChartInterval].forEach {
            userDefaults.removeObject(forKey: $0)
        }
        userDefaults.synchronize()
    }
    
    public var totalValueChartInterval: Interval {
        get {
            userDefaults.getEnum(
                Interval.self,
                forKey: Keys.totalValueChartInterval,
                allowedValues: Consts.historyChartIntervals,
                defaultValue: Consts.defaultHistoryChartInterval
            )
        }
        set(newValue) {
            userDefaults.saveEnum(newValue, forKey: Keys.totalValueChartInterval)
        }
    }
    
    public var categoriesValueChartInterval: Interval {
        get {
            userDefaults.getEnum(
                Interval.self,
                forKey: Keys.categoriesValueChartInterval,
                allowedValues: Consts.historyChartIntervals,
                defaultValue: Consts.defaultHistoryChartInterval
            )
        }
        set(newValue) {
            userDefaults.saveEnum(newValue, forKey: Keys.categoriesValueChartInterval)
        }
    }
}

private extension UserDefaults {
    func getEnum<T: RawRepresentable & Equatable>(_ type: T.Type, forKey key: String, allowedValues: [T]? = nil, defaultValue: T) -> T where T.RawValue == String {
        guard
            let rawValue = self.string(forKey: key),
            let value = T(rawValue: rawValue),
            allowedValues?.contains(value) ?? true
            else { return defaultValue }
        return value
    }
    
    func saveEnum<T: RawRepresentable & Equatable>(_ enumValue: T, forKey key: String) {
        self.set(enumValue.rawValue, forKey: key)
        self.synchronize()
    }
}
