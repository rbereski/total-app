//
//  TotalAppTests.swift
//  TotalAppTests
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation
import Testing
@testable import Total

struct TotalAppTests {
    @Test
    func testPriceDataProvider() async throws {
        let provider1 = BinancePriceDataProvider()
        let r1 = try await provider1.fetchPrice(symbol: "BTC")
        #expect(r1.price > 0)
        
        let provider2 = KuCoinPriceDataProvider()
        let r2 = try await provider2.fetchPrice(symbol: "BTC")
        #expect(r2.price > 0)
        
        let provider3 = BankierPriceDataProvider()
        let r3 = try await provider3.fetchPrice(symbol: "CDPROJEKT")
        #expect(r3.price > 0)
    }
    
    @Test
    func testAssetEntityMapping() {
        let asset = Asset(
            id: UUID(uuidString: "88DC84A8-A43F-4E1B-B69C-244371B08754")!,
            modifiedTs: 1744282233,
            type: .crypto,
            name: "ETH Wallet",
            amount: 2.1,
            currency: .usd,
            location: "Binance",
            tag: "l1",
            priceProviderId: "binance-api",
            priceProviderSymbol: "ETH",
            fixedPrice: 1800.0,
            parentId: UUID(uuidString: "74C46005-F778-48CB-8039-B485916C092B")!,
            position: 5
        )
        
        let entity = AssetEntity(from: asset)
        let restored = Asset(from: entity)
        let copied = Asset(asset: asset)
        
        #expect(asset.id == UUID(uuidString: "88DC84A8-A43F-4E1B-B69C-244371B08754")!)
        #expect(asset.modifiedTs == 1744282233)
        #expect(asset.type == .crypto)
        #expect(asset.name == "ETH Wallet")
        #expect(asset.amount == 2.1)
        #expect(asset.currency == .usd)
        #expect(asset.location == "Binance")
        #expect(asset.tag == "l1")
        #expect(asset.priceProviderId == "binance-api")
        #expect(asset.priceProviderSymbol == "ETH")
        #expect(asset.fixedPrice == 1800.0)
        #expect(asset.parentId == UUID(uuidString: "74C46005-F778-48CB-8039-B485916C092B")!)
        #expect(asset.position == 5)
        
        #expect(asset.id == entity.id)
        #expect(asset.modifiedTs == entity.modifiedTs)
        #expect(asset.type == entity.type)
        #expect(asset.name == entity.name)
        #expect(asset.amount == entity.amount)
        #expect(asset.currency == entity.currency)
        #expect(asset.location == entity.location)
        #expect(asset.tag == entity.tag)
        #expect(asset.priceProviderId == entity.priceProviderId)
        #expect(asset.priceProviderSymbol == entity.priceProviderSymbol)
        #expect(asset.fixedPrice == entity.fixedPrice)
        #expect(asset.parentId == entity.parentId)
        #expect(asset.position == entity.position)
        
        #expect(asset.id == restored.id)
        #expect(asset.modifiedTs == restored.modifiedTs)
        #expect(asset.type == restored.type)
        #expect(asset.name == restored.name)
        #expect(asset.amount == restored.amount)
        #expect(asset.currency == restored.currency)
        #expect(asset.location == restored.location)
        #expect(asset.tag == restored.tag)
        #expect(asset.priceProviderId == restored.priceProviderId)
        #expect(asset.priceProviderSymbol == restored.priceProviderSymbol)
        #expect(asset.fixedPrice == restored.fixedPrice)
        #expect(asset.parentId == restored.parentId)
        #expect(asset.position == restored.position)
        
        #expect(asset.id == copied.id)
        #expect(asset.modifiedTs == copied.modifiedTs)
        #expect(asset.type == copied.type)
        #expect(asset.name == copied.name)
        #expect(asset.amount == copied.amount)
        #expect(asset.currency == copied.currency)
        #expect(asset.location == copied.location)
        #expect(asset.tag == copied.tag)
        #expect(asset.priceProviderId == copied.priceProviderId)
        #expect(asset.priceProviderSymbol == copied.priceProviderSymbol)
        #expect(asset.fixedPrice == copied.fixedPrice)
        #expect(asset.parentId == copied.parentId)
        #expect(asset.position == copied.position)
    }
    
    @Test
    func testTotalValueLogEntryMapping() {
        let value = TotalValue(
            createdTs: 1744282233,
            intervalTs: 1744243200,
            valueBtc: 0.001,
            valueUsd: 100,
            valueCurr1: 120,
            valueCurr2: 140,
            valueCurr3: 160
        )
        
        #expect(value.createdTs == 1744282233)
        #expect(value.intervalTs == 1744243200)
        #expect(value.valueBtc == 0.001)
        #expect(value.valueUsd == 100)
        #expect(value.valueCurr1 == 120)
        #expect(value.valueCurr2 == 140)
        #expect(value.valueCurr3 == 160)
        
        let entity = TotalValueEntity(from: value)
        #expect(value.createdTs == entity.createdTs)
        #expect(value.intervalTs == entity.intervalTs)
        #expect(value.valueBtc == entity.valueBtc)
        #expect(value.valueUsd == entity.valueUsd)
        #expect(value.valueCurr1 == entity.valueCurr1)
        #expect(value.valueCurr2 == entity.valueCurr2)
        #expect(value.valueCurr3 == entity.valueCurr3)
        
        let valueRestored = TotalValue(from: entity)
        #expect(valueRestored.createdTs == entity.createdTs)
        #expect(valueRestored.intervalTs == entity.intervalTs)
        #expect(valueRestored.valueBtc == entity.valueBtc)
        #expect(valueRestored.valueUsd == entity.valueUsd)
        #expect(valueRestored.valueCurr1 == entity.valueCurr1)
        #expect(valueRestored.valueCurr2 == entity.valueCurr2)
        #expect(valueRestored.valueCurr3 == entity.valueCurr3)
    }
    
    @Test
    func testCategoryValueLogEntryMapping() {
        let value = CategoryValue(
            createdTs: 1744282233,
            intervalTs: 1744243200,
            assetType: .crypto,
            valueBtc: 0.001,
            valueUsd: 100,
            valueCurr1: 120,
            valueCurr2: 140,
            valueCurr3: 160
        )
        
        #expect(value.createdTs == 1744282233)
        #expect(value.intervalTs == 1744243200)
        #expect(value.assetType == .crypto)
        #expect(value.valueBtc == 0.001)
        #expect(value.valueUsd == 100)
        #expect(value.valueCurr1 == 120)
        #expect(value.valueCurr2 == 140)
        #expect(value.valueCurr3 == 160)
        
        let entity = CategoryValueEntity(from: value)
        #expect(value.createdTs == entity.createdTs)
        #expect(value.intervalTs == entity.intervalTs)
        #expect(value.assetType == entity.assetType)
        #expect(value.valueBtc == entity.valueBtc)
        #expect(value.valueUsd == entity.valueUsd)
        #expect(value.valueCurr1 == entity.valueCurr1)
        #expect(value.valueCurr2 == entity.valueCurr2)
        #expect(value.valueCurr3 == entity.valueCurr3)
        
        let valueRestored = CategoryValue(from: entity)
        #expect(valueRestored.createdTs == entity.createdTs)
        #expect(valueRestored.intervalTs == entity.intervalTs)
        #expect(valueRestored.valueBtc == entity.valueBtc)
        #expect(valueRestored.valueUsd == entity.valueUsd)
        #expect(valueRestored.valueCurr1 == entity.valueCurr1)
        #expect(valueRestored.valueCurr2 == entity.valueCurr2)
        #expect(valueRestored.valueCurr3 == entity.valueCurr3)
    }
    
    
    @Test
    func testIntervalStartTimestamp() {
        #expect(Interval.h24.startTimestamp(ts: 1744282233) == 1744243200)
    }
}
