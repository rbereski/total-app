//
//  EditAPIKeyView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 24/05/2025.
//

import SwiftUI
import AlertToast

struct EditAPIKeyView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var apiKey: APIKey
    private var viewModel: SettingsViewModel
    private var isCustomKey: Bool
    private let isNewKey: Bool
    @State private var errorMessage = ""
    @State private var errorVisible = false
    
    init(viewModel: SettingsViewModel, apiKey: APIKey) {
        self.viewModel = viewModel
        self.apiKey = APIKey(apiKey: apiKey) // copy
        self.isCustomKey = apiKey.provider == .unspecified
        self.isNewKey = apiKey.id.isEmpty && isCustomKey
    }
    
    var body: some View {
        NavigationView {
            Form {
                EditorSection(title: "ID") {
                    if (isCustomKey) {
                        TextField("Enter ID", text: $apiKey.id)
                            .autocorrectionDisabled()
                            .autocapitalization(.none)
                    } else {
                        Text(apiKey.id)
                    }
                }
                
                EditorSection(title: "Key") {
                    TextField("Enter API key", text: $apiKey.key)
                        .autocorrectionDisabled()
                        .autocapitalization(.none)
                }
                
                FormConfirmButton("Save") {
                    if (apiKey.id.isEmpty) {
                        return showValidationError("ID is required")
                    }
                    
                    if (apiKey.key.isEmpty) {
                        return showValidationError("Key is required")
                    }
                    
                    Task {
                        do {
                            try await viewModel.save(apiKey: apiKey)
                            dismiss()
                        } catch let e as ConfigError {
                            showValidationError(e.description)
                        }
                    }
                }
                .padding(.top, 12)
                .disabled(apiKey.id.isEmpty && apiKey.key.isEmpty)
            }
            .navigationBarTitle(isNewKey ? "New API key" : "Edit API Key", displayMode: .inline)
            .toast(isPresenting: $errorVisible, duration: 2, tapToDismiss: true) {
                AlertToast(displayMode: .banner(.pop), type: .error(.red), title: errorMessage)
            }
        }
    }
    
    func showValidationError(_ message: String) {
        errorMessage = message
        errorVisible = true
    }
}
