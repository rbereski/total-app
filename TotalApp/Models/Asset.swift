//
//  Asset.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation
import SwiftData

@Observable
public class Asset: Identifiable, PersistentModelType {
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
    public var persistentId: PersistentIdentifier?

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
        position: Int = 0,
        persistentId: PersistentIdentifier? = nil
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
        self.persistentId = persistentId
    }
    
    public convenience init(
        asset: Asset
    ) {
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
            position: asset.position,
            persistentId: asset.persistentId
        )
    }
    
    public convenience init(
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
        self.init(
            id: UUID(),
            modifiedTs: Timestamp.current,
            type: type,
            name: name,
            amount: amount,
            currency: currency,
            priceProviderId: priceProviderId,
            priceProviderSymbol: priceProviderSymbol,
            fixedPrice: fixedPrice,
            parentId: parentId,
            position: position
        )
    }
    
    public init(from entity: AssetEntity) {
        self.id = entity.id
        self.modifiedTs = entity.modifiedTs
        self.type = entity.type
        self.name = entity.name
        self.amount = entity.amount
        self.currency = entity.currency
        self.location = entity.location
        self.tag = entity.tag
        self.priceProviderId = entity.priceProviderId
        self.priceProviderSymbol = entity.priceProviderSymbol
        self.fixedPrice = entity.fixedPrice
        self.parentId = entity.parentId
        self.position = entity.position
        self.persistentId = entity.persistentModelID
    }
}
