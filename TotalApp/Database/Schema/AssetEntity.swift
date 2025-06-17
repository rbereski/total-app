//
//  AssetEntity.swift
//  TotalApp
//
//  Created by Rafal Bereski on 03/05/2025.
//

import Foundation
import SwiftData

@Model
public class AssetEntity {
    public var id: UUID
    public var modifiedTs: Int
    public var type: AssetType
    public var name: String
    public var amount: Double
    public var currency: Currency
    public var location: String?
    public var tag: String?
    public var priceProviderId: String?
    public var priceProviderSymbol: String?
    public var fixedPrice: Double
    public var parentId: UUID?
    public var position: Int
    
    public init(
        id: UUID,
        modifiedTs: Int,
        type: AssetType,
        name: String,
        amount: Double,
        currency: Currency,
        location: String? = nil,
        tag: String? = nil,
        priceProviderId: String? = nil,
        priceProviderSymbol: String? = nil,
        fixedPrice: Double = 0,
        parentId: UUID? = nil,
        position: Int = 0
    ) {
        self.id = id
        self.modifiedTs = modifiedTs
        self.type = type
        self.name = name
        self.amount = amount
        self.currency = currency
        self.location = location
        self.tag = tag
        self.priceProviderId = priceProviderId
        self.priceProviderSymbol = priceProviderSymbol
        self.fixedPrice = fixedPrice
        self.parentId = parentId
        self.position = position
    }
    
    public convenience init(from asset: Asset) {
        self.init(
            id: asset.id,
            modifiedTs: asset.modifiedTs,
            type: asset.type,
            name: asset.name,
            amount: asset.amount,
            currency: asset.currency,
            location: asset.location,
            tag: asset.tag,
            priceProviderId: asset.priceProviderId,
            priceProviderSymbol: asset.priceProviderSymbol,
            fixedPrice: asset.fixedPrice,
            parentId: asset.parentId,
            position: asset.position
        )
    }
    
    public func applyChanges(_ model: Asset) {
        assert(self.id == model.id)
        self.modifiedTs = model.modifiedTs
        self.type = model.type
        self.name = model.name
        self.amount = model.amount
        self.currency = model.currency
        self.location = location
        self.tag = tag
        self.priceProviderId = model.priceProviderId
        self.priceProviderSymbol = model.priceProviderSymbol
        self.fixedPrice = model.fixedPrice
        self.parentId = model.parentId
        self.position = model.position
    }
}
