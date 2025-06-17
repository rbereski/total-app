//
//  FormPriceProviderPicker.swift
//  TotalApp
//
//  Created by Rafal Bereski on 12/05/2025.
//

import SwiftUI

struct FormPriceProviderPicker: View {
    var assetType: AssetType
    var providerId: Binding<PriceDataProviderID>
    var fixedPrice: Binding<Double>
    var providers: [PriceDataProviderID]
    
    public init(assetType: AssetType, providerId: Binding<PriceDataProviderID>, fixedPrice: Binding<Double>) {
        self.assetType = assetType
        self.providerId = providerId
        self.fixedPrice = fixedPrice
        self.providers = PriceDataProviderID.allCases.filter {
            $0.supportedAssets.contains(assetType)
        }
    }
    
    var body: some View {
        Picker("Source", selection: providerId) {
            ForEach(providers, id: \.self) { provider in
                Text(provider.providerName).tag(provider)
            }
        }
        .onChange(of: providerId.wrappedValue) {
            fixedPrice.wrappedValue = 0.0
        }
        .pickerStyle(.navigationLink)
    }
}
