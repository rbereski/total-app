//
//  FormCurrencyPicker.swift
//  TotalApp
//
//  Created by Rafal Bereski on 08/05/2025.
//

import SwiftUI

struct FormCurrencyPicker: View {
    @Binding var curr: Currency
    
    var body: some View {
        Picker("Currency", selection: $curr) {
            ForEach(Currency.allCases.filter { $0.isFiat }) { curr in
                Text(curr.symbol).tag(curr)
            }
        }
        .pickerStyle(.navigationLink)
    }
}
