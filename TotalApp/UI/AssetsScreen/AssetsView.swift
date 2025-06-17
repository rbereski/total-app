//
//  AssetsView.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import SwiftUI
import SwiftData

struct AssetsView: View {
    @Environment(ViewSettings.self) private var viewSettings : ViewSettings
    @State private var isExpanded: Set<AssetType> = Set(AssetType.allCases)
    let categories: [AssetType] = [.cash, .crypto, .stock, .commodity, .real, .other]
    var viewModel: AssetsViewModel
    
    @State var selectedNewAssetType: AssetType?
    @State var selectedAssetToEdit: Asset?
    @State var selectedAssetToChangeAmount: Asset?
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                
                Group {
                    if (!viewModel.isEmpty) {
                        List(categories, id: \.self) { assetType in
                            if viewModel.categories[assetType]?.count ?? 0 > 0 {
                                Section(isExpanded: Binding<Bool>(
                                    get: { isExpanded.contains(assetType) },
                                    set: { expanding in
                                        if expanding {
                                            isExpanded.insert(assetType)
                                        } else {
                                            isExpanded.remove(assetType)
                                        }
                                    }
                                )) {
                                    ForEach(viewModel.categories[assetType] ?? [], id: \.id) { item in
                                        AssetListItemView(
                                            item: item,
                                            editAction: edit,
                                            editAmountAction: editAmount,
                                            selectedCurrency: viewSettings.selectedCurrency
                                        )
                                    }
                                    .onMove { srcIndexSet, destIndex in
                                        moveAsset(srcIndices: srcIndexSet, destIndex: destIndex, category: assetType)
                                    }
                                    .onDelete { indexSet in
                                        viewModel.delete(at: indexSet, category: assetType)
                                    }
                                } header: {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(assetType.color)
                                            .frame(width: 8, height: 8)
                                        Text(assetType.categoryTitle.uppercased())
                                    }
                                    .listRowInsets(EdgeInsets(top: 8, leading: 2, bottom: 8, trailing: 0))
                                }
                            }
                        }
                        .listStyle(.sidebar)
                        .selectionDisabled()
                        .scrollContentBackground(.hidden)
                        .backgroundStyle(.clear)
                        .environment(\.defaultMinListRowHeight, 54)
                    } else {
                        ContentUnavailableView("No assets found", systemImage: "list.bullet.clipboard", description: Text("Use the (+) button to add one."))
                    }
                }
                       
                .sheet(item: $selectedAssetToEdit) { asset in
                    EditAssetView.update(asset, viewModel: viewModel)
                }
                .sheet(item: $selectedNewAssetType) { type in
                    EditAssetView.create(type, viewModel: viewModel)
                }
                .sheet(item: $selectedAssetToChangeAmount) { asset in
                    EditAmountView(asset: asset, viewModel: viewModel)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
            .navigationTitle("Assets")
            .toolbar { toolbarContent() }
        }
        .task { await viewModel.refreshLists() }
    }
    
    
    private func edit(asset: Asset) {
        selectedAssetToEdit = asset
    }
    
    private func editAmount(asset: Asset) {
        selectedAssetToChangeAmount = asset
    }

    private func moveAsset(srcIndices: IndexSet, destIndex: Int, category: AssetType) {
        viewModel.move(from: srcIndices, to: destIndex, category: category)
    }
    
    @ToolbarContentBuilder
    func toolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                ForEach(categories) { category in
                    Button(
                        action: { selectedNewAssetType = category },
                        label: { Text(category.title) }
                    )
                }
            }
            label: {
                Label("Add", systemImage: "plus")
            }
        }
    }
}
