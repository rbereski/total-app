//
//  OverviewCurrencyButton.swift
//  TotalApp
//
//  Created by Rafal Bereski on 08/05/2025.
//

import SwiftUI

struct OverviewCurrencyButton: View {
    var currency: Currency
    var viewSettings: ViewSettings
    var action: () -> Void
    
    var body: some View {
        Button(currency.symbol, action: action)
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .tint(currency == viewSettings.selectedCurrency ? Color.accentColor : Color.currencyButtonBkg)
            .padding(EdgeInsets(top: 2, leading: 4, bottom: 16, trailing: 4))
    }
}
