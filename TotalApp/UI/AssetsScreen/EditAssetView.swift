//
//  EditAssetView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 08/05/2025.
//


import Foundation
import SwiftUI
import AlertToast

enum EditAssetMode {
    case create
    case update
    
    var formTitle: String {
        switch self {
            case .create: return "New Asset"
            case .update: return "Edit Asset"
        }
    }
}

struct EditAssetView: View {
    public static func create(_ assetType: AssetType, currency: Currency = .usd, viewModel: AssetsViewModel) -> EditAssetView {
        let asset = Asset(type: assetType, name: "", amount: 0.0, currency: currency)
        return EditAssetView(asset: asset, mode: .create, viewModel: viewModel)
    }
    
    public static func update(_ asset: Asset, viewModel: AssetsViewModel) -> EditAssetView {
        return EditAssetView(asset: asset, mode: .update, viewModel: viewModel)
    }
    
    private init(asset: Asset, mode: EditAssetMode, viewModel: AssetsViewModel) {
        self.asset = Asset(asset: asset)
        self.mode = mode
        self.viewModel = viewModel
        self.providerId = mode == .create
            ? .defaultPriceProvider(forCategory: asset.type)
            : .parse(asset.priceProviderId, defaultProvider: .fixedPrice)
    }
    
    @Environment(\.dismiss) private var dismiss
    @Bindable private var asset: Asset
    private let mode: EditAssetMode
    private var viewModel: AssetsViewModel
    @State private var providerId: PriceDataProviderID
    @State private var symbolValidationState: OperationState = .none
    @State private var symbolErrorMessage: String?
    @State private var isToastVisible: Bool = false
    
    
    var body: some View {
        NavigationView {
            Form {
                let formatter = NumberFormattersCache.shared.editorDecimalFormatter
                
                Label(
                    title: { Text(asset.type.title).foregroundStyle(.secondary) },
                    icon: { Image(systemName: asset.type.iconName).foregroundStyle(asset.type.color) }
                )
                
                EditorSection(title: "Asset Name") {
                    TextField("Name", text: $asset.name)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
                
                EditorSection(title: "Amount") {
 
                    TextField("Amount", value: $asset.amount, formatter: formatter).keyboardType(.decimalPad)
                    if asset.type == .cash {
                        FormCurrencyPicker(curr: $asset.currency)
                    }
                }
                
                if (asset.type != .cash) {
                    EditorSection(title: "Symbol") {
                        TextField("Symbol", text: $asset.priceProviderSymbol.bound)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    }
                    
                    EditorSection(title: "Price") {
                        FormPriceProviderPicker(assetType: asset.type, providerId: $providerId, fixedPrice: $asset.fixedPrice)
                        if providerId == .fixedPrice {
                            TextField("Fixed Price", value: $asset.fixedPrice, formatter: formatter).keyboardType(.decimalPad)
                            FormCurrencyPicker(curr: $asset.currency)
                        }
                    }
                }
                
                EditorSection(title: "Location (Optional)") {
                    TextField("e.g. Bank, Exchange ...", text: $asset.location.bound)
                }
                
                EditorSection(title: "Tag (Optional)") {
                    TextField("e.g. ETF, AltCoin ...", text: $asset.tag.bound)
                }
                
                FormConfirmButton("Save") {
                    didTapSave()
                }
                .padding(.top, 12)
            }
            .navigationBarTitle(mode.formTitle, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        didTapCancel()
                    }
                }
            }
            .toast(isPresenting: $isToastVisible, duration: 0, tapToDismiss: true) {
                switch symbolValidationState {
                    case .inProgress: return AlertToast(type: .loading, title: "Checking symbol...")
                    case .failed: return AlertToast(type: .error(.red), title: symbolErrorMessage)
                    default: return AlertToast(type: .loading)
                }
            }
        }
    }
    
    func didTapSave() {
        Task {
            guard symbolValidationState != .inProgress else { return }
            let validationRequired = asset.type != .cash && providerId != .fixedPrice
            if (validationRequired) {
                if await validateSymbol() {
                    await saveAndDismiss()
                } else {
                    await handleSymbolValidationError()
                }
            } else {
                await saveAndDismiss()
            }
        }
    }
    
    func didTapCancel() {
        dismiss()
    }
    
    private func validateSymbol() async -> Bool {
        symbolValidationState = .inProgress
        
        isToastVisible = true
        let result = await viewModel.verify(assetSymbol: asset.priceProviderSymbol ?? "", withProvider: providerId)
        isToastVisible = false
        
        switch result {
            case .providerNotConfigured: symbolErrorMessage = "Selected price data source is not configured."
            case .unrecognized: symbolErrorMessage = "Symbol not recognized."
            case .recognized: break
        }
        
        return result == .recognized
    }
    
    private func saveAndDismiss() async {
        isToastVisible = false
        symbolValidationState = .none
        asset.priceProviderId = providerId != .fixedPrice ? providerId.rawValue : nil
        await viewModel.save(asset)
        dismiss()
    }
    
    private func handleSymbolValidationError() async {
        symbolValidationState = .failed
        isToastVisible = true
        try? await Task.sleep(for: .milliseconds(1500))
        isToastVisible = false
    }
}
