//
//  OverviewSection.swift
//  TotalApp
//
//  Created by Rafal Bereski on 06/06/2025.
//

import SwiftUI

struct OverviewSection<Content: View>: View {
    @State var title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.init(top: 0, leading: 0, bottom: 12, trailing: 0))
            content
        }
        .padding(.init(top: 12, leading: 12, bottom: 12, trailing: 12))
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
