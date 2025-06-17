//
//  FormConfirmButton.swift
//  TotalApp
//
//  Created by Rafal Bereski on 08/05/2025.
//

import SwiftUI

struct FormConfirmButton: View {
    var text: String
    var action: () -> Void
    
    init(_ text: String, action: @escaping () -> Void) {
        self.text = text
        self.action = action
    }
    
    var body: some View {
        Section {
            Button() {
                action()
            } label : {
                Text(text)
                    .bold()
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
    }
}
