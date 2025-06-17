//
//  CurrencyPickerWidget.swift
//  TotalApp
//
//  Created by Rafal Bereski on 11/06/2025.
//

import SwiftUI

struct CurrencyPickerWidget: View {
    @Binding var selectedCurrency: Currency
    var supportedCurrencies: [Currency]
    var action: (Currency) -> Void
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                ForEach(supportedCurrencies, id: \.self) { currency in
                    Button(currency.symbol, action: { action(currency) })
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                        .tint(currency == selectedCurrency ? .accentColor : .currencyButtonBkg)
                        .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                }
            }
        }
    }
}
