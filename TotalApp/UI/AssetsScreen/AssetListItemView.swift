//
//  CashRow.swift
//  TotalApp
//
//  Created by Rafal Bereski on 11/05/2025.
//

import SwiftUI
import SwiftData

struct AssetListItemView: View {
    @Environment(\.sizeCategory) private var sizeCategory
    static let font14 = Font.system(size: UIFontMetrics.default.scaledValue(for: 14))
    static let font13 = Font.system(size: UIFontMetrics.default.scaledValue(for: 13))
    var item: AssetListItem
    var editAction: (Asset) -> Void
    var editAmountAction: (Asset) -> Void
    var selectedCurrency: Currency
    
    var body: some View {
        HStack {
            nameAndSymbol
            Spacer()
            valueAndAmount
            Spacer().frame(width: 20)
            editButton
        }
        .contentShape(Rectangle())
        .padding(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
        .onTapGesture {
            editAmountAction(item.asset)
        }
    }
    
    private var modifiedBadge : some View {
        HStack(spacing: 6) {
            Image(systemName: "pencil")
            Text("Modified")
        }
        .font(.caption)
        .bold()
        .foregroundStyle(.modifiedBadge)
    }
    
    private var nameAndSymbol : some View {
        VStack(alignment: .leading) {
            Text(item.asset.name)
                .font(Self.font13)
                .foregroundStyle(.primary)
            Text(item.asset.type == .cash ? item.asset.currency.symbol : item.asset.priceProviderSymbol ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
    
    private var valueAndAmount: some View {
        VStack(alignment: .trailing) {
            if !item.upToDate {
                modifiedBadge
            } else {
                Text(NumberFormattersCache.shared.format(price: item.values[selectedCurrency] ?? 0, currency: selectedCurrency))
                    .font(Self.font14)
                    .bold()
                    .foregroundStyle(.primary)
            }
            
            if item.asset.type == .cash {
                Text(NumberFormattersCache.shared.format(price: item.asset.amount, currency: item.asset.currency))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Amount: \(NumberFormattersCache.shared.format(decimal: item.asset.amount))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    var editButton: some View {
        Button(
            action: { editAction(item.asset) },
            label: { Image(systemName:"ellipsis.circle") }
        )
        .buttonStyle(.borderless)
        .controlSize(.regular)
    }
}
