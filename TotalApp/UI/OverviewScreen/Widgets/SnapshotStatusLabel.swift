//
//  SnapshotStateLabel.swift
//  TotalApp
//
//  Created by Rafal Bereski on 10/06/2025.
//

import SwiftUI

struct SnapshotStateLabel: View {
    var state: SnapshotState
    
    var body: some View {
        if case .none = state {
            EmptyView()
        } else {
            HStack(spacing: 4) {
                Image(systemName: symbolName)
                    .font(.caption)
                    .foregroundStyle(color.opacity(0.75))
                Text(text)
                    .font(.caption2)
                    .foregroundStyle(color.opacity(0.75))
            }
        }
    }
    
    var text: String {
        switch state {
            case .upToDate: return "Up to date"
            case .outdated: return "Outdated"
            case .invalidated: return "Outdated (modified assets)"
            default: return ""
        }
    }
    
    var symbolName: String {
        switch state {
            case .upToDate: return "checkmark.circle"
            case .outdated: return "clock.badge.exclamationmark"
            case .invalidated: return "clock.badge.exclamationmark"
            default: return ""
        }
    }
    
    var color: Color {
        switch state {
            case .upToDate: return .secondary
            case .outdated: return .snapshotStateOutdated
            case .invalidated: return .snapshotStateOutdated
            default: return .secondary
        }
    }
}
