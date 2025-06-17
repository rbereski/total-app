//
//  SetupCurrencyPicker.swift
//  TotalApp
//
//  Created by Rafal Bereski on 24/05/2025.
//

import SwiftUI
import SwiftData
import AlertToast

struct SetupCurrencyPicker: View {
    private var requiredCurrencies: Binding<[Currency]>
    private var optionalCurrencies: Binding<[Currency]>
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCurrency: Currency?
    private var currencies: [Currency]
    
    public init(
        requiredCurrencies: Binding<[Currency]>,
        optionalCurrencies: Binding<[Currency]>
    ) {
        self.requiredCurrencies = requiredCurrencies
        self.optionalCurrencies = optionalCurrencies
        self.currencies = Currency.allCases.filter {
            !optionalCurrencies.wrappedValue.contains($0)
                && !requiredCurrencies.wrappedValue.contains($0)
        }
    }
    
    var body: some View {
        VStack {
            List(currencies, id:\.self, selection: $selectedCurrency) { currency in
                Text(currency.symbol)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Currencies")
        .onChange(of: selectedCurrency) { (_, newValue: Currency?) in
            guard let newValue else { return }
            optionalCurrencies.wrappedValue.append(newValue)
            dismiss()
        }
    }
}
