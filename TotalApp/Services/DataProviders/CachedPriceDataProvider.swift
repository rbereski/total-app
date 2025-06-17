//
//  CachedPriceDataProvider.swift
//  TotalApp
//
//  Created by Rafal Bereski on 08/06/2025.
//

public class CachedPriceDataProvider: PriceDataProviderType {
    private let provider: PriceDataProviderType
    private let cacheDuration: Interval
    private var cache: [String: AssetPrice] = [:]
    
    public init(provider: PriceDataProviderType, cacheDuration: Interval = .m15) {
        self.provider = provider
        self.cacheDuration = cacheDuration
    }
    
    public var id: PriceDataProviderID {
        provider.id
    }
    
    public func configure(with configManager: ConfigManager) async throws(DataProviderError) {
        try await provider.configure(with: configManager)
    }
 
    public func fetchPrice(symbol: String) async throws(DataProviderError) -> AssetPrice {
        if let cachedAssetPrice = cache[symbol], Timestamp.current < cachedAssetPrice.timestamp + cacheDuration.duration {
            return cachedAssetPrice
        }
        
        let assetPrice = try await provider.fetchPrice(symbol: symbol)
        cache[symbol] = assetPrice
        return assetPrice
    }
}
