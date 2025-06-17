//
//  APIKeysListItemView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 24/05/2025.
//

import SwiftUI

struct APIKeysListItemView: View {
    var apiKey: APIKey
    var editAction: (APIKey) -> Void
    
    var body: some View {
        HStack {
            VStack(spacing: 2) {
                if (apiKey.provider != .unspecified) {
                    Text("\(apiKey.provider.name)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle(.primary)
                        .font(.body)
                        .bold()
                        .padding(.bottom, 2)
                }
                Text("ID: \(apiKey.id)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .bold()
                Text("API Key: \(String(repeating: "*", count: min(apiKey.key.count, 32)))")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .bold()
            }
            Spacer().frame(width: 20)
            editButton
        }
    }
    
    var editButton: some View {
        Button(action: { editAction(apiKey) }, label: { Text("Edit") })
            .buttonStyle(.borderless)
    }
}
