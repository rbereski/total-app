//
//  CashAssetEditView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation
import SwiftUI

struct EditAmountView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var asset: Asset
    @FocusState private var isFocused: Bool
    private let viewModel: AssetsViewModel
    
    init(asset: Asset, viewModel: AssetsViewModel) {
        self.asset = Asset(asset: asset) // copy
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            Form {
                let formatter = NumberFormattersCache.shared.editorDecimalFormatter
                
                EditorSection(title: asset.type.title) {
                    Text(asset.name)
                }
                
                EditorSection(title: amountUnit(asset).map { "Amount (\($0))" } ?? "Amount") {
                    TextField("Enter Amount", value: $asset.amount, formatter: formatter)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .font(.title)
                        .padding(12)
                        .focused($isFocused)
                }
                
                FormConfirmButton("Save") {
                    didTapSave()
                }
                .padding(.top, 12)
            }
            .navigationBarTitle("Change Amount", displayMode: .inline)
            .onAppear { isFocused = true }
        }
    }
    
    private func amountUnit(_ asset : Asset) -> String? {
        return asset.type == .cash ? asset.currency.symbol : asset.priceProviderSymbol
    }
    
    private func didTapSave() {
        Task {
            await viewModel.save(asset)
            dismiss()
        }
    }
}
