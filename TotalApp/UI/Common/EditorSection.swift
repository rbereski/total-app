//
//  EditorSection.swift
//  TotalApp
//
//  Created by Rafal Bereski on 12/05/2025.
//

import SwiftUI

struct EditorSection<Content: View>: View {
    @State var title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        Section {
            content
        } header: {
            Text(title)
                .listRowInsets(.init())
        }
        .listSectionSpacing(32)
    }
}
