//
//  Currency.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation

public enum Currency: String, CaseIterable, Codable, Identifiable, Sendable {
    case btc = "BTC"
    case usd = "USD"
    case eur = "EUR"
    case cad = "CAD"
    case cny = "CNY"
    case jpy = "JPY"
    case aud = "AUD"
    case pln = "PLN"
    case czk = "CZK"
    case bgn = "BGN"
    case dkk = "DKK"
    case gbp = "GBP"
    case huf = "HUF"
    case ron = "RON"
    case sek = "SEK"
    case chf = "CHF"
    case isk = "ISK"
    case nok = "NOK"
    case hrk = "HRK"
    case rub = "RUB"
    case brl = "BRL"
    case hkd = "HKD"
    case idr = "IDR"
    case ils = "ILS"
    case inr = "INR"
    case krw = "KRW"
    case mxn = "MXN"
    case myr = "MYR"
    case nzd = "NZD"
    case php = "PHP"
    case sgd = "SGD"
    case thb = "THB"
    case zar = "ZAR"
    case `try` = "TRY"
    
    public init?(rawValue: String) {
        switch rawValue {
            case "BTC": self = .btc
            case "USD": self = .usd
            case "EUR": self = .eur
            case "CZK": self = .czk
            case "PLN": self = .pln
            case "JPY": self = .jpy
            case "BGN": self = .bgn
            case "DKK": self = .dkk
            case "GBP": self = .gbp
            case "HUF": self = .huf
            case "RON": self = .ron
            case "SEK": self = .sek
            case "CHF": self = .chf
            case "ISK": self = .isk
            case "NOK": self = .nok
            case "HRK": self = .hrk
            case "RUB": self = .rub
            case "AUD": self = .aud
            case "BRL": self = .brl
            case "CAD": self = .cad
            case "CNY": self = .cny
            case "HKD": self = .hkd
            case "IDR": self = .idr
            case "ILS": self = .ils
            case "INR": self = .inr
            case "KRW": self = .krw
            case "MXN": self = .mxn
            case "MYR": self = .myr
            case "NZD": self = .nzd
            case "PHP": self = .php
            case "SGD": self = .sgd
            case "THB": self = .thb
            case "ZAR": self = .zar
            case "TRY": self = .try
            default: return nil
        }
    }
    
    public var id: String {
        return self.rawValue
    }
    
    public var symbol: String {
        rawValue
    }
    
    public var name: String {
        rawValue
    }
    
    public var isFiat: Bool {
        self != .btc
    }
    
    public var isCrypto: Bool {
        self == .btc
    }
    
    public var locale: Locale {
        switch self {
            case .usd: return Locale(identifier: "en_US")
            case .eur: return Locale(identifier: "de_DE")
            case .czk: return Locale(identifier: "cs_CZ")
            case .pln: return Locale(identifier: "pl_PL")
            case .jpy: return Locale(identifier: "ja_JP")
            case .bgn: return Locale(identifier: "bg_BG")
            case .dkk: return Locale(identifier: "da_DK")
            case .gbp: return Locale(identifier: "en_GB")
            case .huf: return Locale(identifier: "hu_HU")
            case .ron: return Locale(identifier: "ro_RO")
            case .sek: return Locale(identifier: "sv_SE")
            case .chf: return Locale(identifier: "de_CH")
            case .isk: return Locale(identifier: "is_IS")
            case .nok: return Locale(identifier: "nb_NO")
            case .hrk: return Locale(identifier: "hr_HR")
            case .rub: return Locale(identifier: "ru_RU")
            case .aud: return Locale(identifier: "en_AU")
            case .brl: return Locale(identifier: "pt_BR")
            case .cad: return Locale(identifier: "en_CA")
            case .cny: return Locale(identifier: "zh_CN")
            case .hkd: return Locale(identifier: "zh_HK")
            case .idr: return Locale(identifier: "id_ID")
            case .ils: return Locale(identifier: "he_IL")
            case .inr: return Locale(identifier: "hi_IN")
            case .krw: return Locale(identifier: "ko_KR")
            case .mxn: return Locale(identifier: "es_MX")
            case .myr: return Locale(identifier: "ms_MY")
            case .nzd: return Locale(identifier: "en_NZ")
            case .php: return Locale(identifier: "en_PH")
            case .sgd: return Locale(identifier: "en_SG")
            case .thb: return Locale(identifier: "th_TH")
            case .zar: return Locale(identifier: "en_ZA")
            case .try: return Locale(identifier: "tr_TR")
            default: return Locale(identifier: "en_US")
        }
    }
}
