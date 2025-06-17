//
//  NumberFormattersCache.swift
//  TotalApp
//
//  Created by Rafal Bereski on 20/05/2025.
//

import Foundation

public class NumberFormattersCache {
    public static let shared = NumberFormattersCache()
    public let decimalSeparator =  "."
    
    private init() {
        /* Empty */
    }
    
    public lazy var intFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = decimalSeparator
        formatter.roundingMode = .halfUp
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    public lazy var editorDecimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = decimalSeparator
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        formatter.groupingSize = 0
        return formatter
    }()
    
    public lazy var axisValueFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = decimalSeparator
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 4
        return formatter
    }()
    
    public lazy var decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = decimalSeparator
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        return formatter
    }()
    
    public lazy var defaultPercentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.decimalSeparator = decimalSeparator
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    public lazy var defaultPriceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = decimalSeparator
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    private lazy var priceFormatters: [Currency: NumberFormatter] = {
        Dictionary(uniqueKeysWithValues: Currency.allCases.map {
            ($0, $0.getPriceFormatter(decimalSeparator: decimalSeparator, groupingSeparator: " "))
        })
    }()
    
    public func priceFormatter(for currency: Currency) -> NumberFormatter {
        return priceFormatters[currency] ?? defaultPriceFormatter
    }

    public func formatAsInteger(decimal: Double) -> String {
        intFormatter.string(from: NSNumber(value: decimal)) ?? ""
    }
    
    public func format(decimal: Double) -> String {
        decimalFormatter.string(from: NSNumber(value: decimal)) ?? ""
    }
    
    public func format(percentage: Double) -> String {
        defaultPercentageFormatter.string(from: NSNumber(value: percentage)) ?? ""
    }
    
    public func format(price: Double, currency: Currency) -> String {
        currency.isFiat
            ? (priceFormatter(for: currency).string(from: NSNumber(value: price)) ?? "")
            : "\(priceFormatter(for: currency).string(from: NSNumber(value: price)) ?? "") \(currency.symbol)"
    }
    
    public func format(axisValue: Double) -> String {
        if axisValue >= 1_000_000 {
            return "\(axisValueFormatter.string(from: NSNumber(value: axisValue / 1_000_000)) ?? "0")M"
        } else if axisValue >= 1_000 {
            return "\(axisValueFormatter.string(from: NSNumber(value: axisValue / 1_000)) ?? "0")K"
        } else {
            return axisValueFormatter.string(from: NSNumber(value: axisValue)) ?? "0"
        }
    }
}

private extension Currency {
    func getPriceFormatter(decimalSeparator: String, groupingSeparator: String) -> NumberFormatter {
        if isFiat {
            let formatter = NumberFormatter()
            formatter.locale = locale
            formatter.numberStyle = .currency
            formatter.groupingSize = 3
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.decimalSeparator = decimalSeparator
            formatter.currencyDecimalSeparator = decimalSeparator
            formatter.groupingSeparator = groupingSeparator
            formatter.currencyGroupingSeparator = groupingSeparator
            return formatter
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 6
            formatter.decimalSeparator = decimalSeparator
            formatter.currencyDecimalSeparator = decimalSeparator
            formatter.groupingSeparator = groupingSeparator
            formatter.currencyGroupingSeparator = groupingSeparator
            return formatter
        }
    }
}
