//
//  KuCoinPriceDataProvider.swift
//  TotalApp
//
//  Created by Rafal Bereski on 12/05/2025.
//

import Foundation

public class KuCoinPriceDataProvider : PriceDataProviderType {
    public let apiUrl = URL(string: "https://api.kucoin.com")!
    public let id: PriceDataProviderID = .kucoin
    private let stablecoins = ["USDT", "USDC"]
    private let currency: Currency = .usd
    private let rateLimitter = RateLimiter(maxRequests: 100, interval: 60.0)
    private let session: URLSession

    
    public init() {
        let config = URLSessionConfiguration.ephemeral
        config.httpShouldSetCookies = false
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: config)
    }
    
    public func configure(with configManager: ConfigManager) async {
        /* Empty */
    }
    
    public func fetchPrice(symbol: String) async throws(DataProviderError) -> AssetPrice {
        await rateLimitter.waitIfNeed()
        
        if (stablecoins.contains(symbol.uppercased())) {
            return .init(symbol: symbol, price: 1.0, currency: currency, timestamp: Timestamp.current)
        }
        
        for stablecoin in stablecoins {
            do {
                return try await fetchPrice(coin: symbol, stablecoin: stablecoin)
            } catch let error {
                if case .invalidSymbol = error { continue }
                throw error
            }
        }
        
        throw invalidSymbol(symbol)
    }

    private func fetchPrice(coin: String, stablecoin: String) async throws(DataProviderError) -> AssetPrice {
        let coin = coin.uppercased()
        let components =  URLComponents(url: apiUrl.appendingPathComponent("/api/v1/market/orderbook/level1"), resolvingAgainstBaseURL: true)!
        let marketPair = "\(coin)-\(stablecoin)"
        let (data, response): (Data, URLResponse)
        let json: [String: Any]
        
        guard let url = components.with({ $0.queryItems = [.init(name: "symbol", value: marketPair )] }).url else {
            throw requestError("Cannot create request URL.")
        }
    
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw requestError("Cannot fetch data from the price provider.")
        }
        
        if (response as? HTTPURLResponse)?.statusCode == 400 {
            throw invalidSymbol(coin)
        }
        
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        } catch {
            throw requestError("Cannot parse JSON data.")
        }
        
        guard
            (response as? HTTPURLResponse)?.statusCode == 200,
            let priceData = json["data"] as? [String: Any],
            let priceStr = priceData["price"] as? String,
            let price = Double(priceStr)
        else {
            throw invalidSymbol(coin)
        }
        
        return .init(
            symbol: coin,
            price: price,
            currency: currency,
            timestamp: Timestamp.current
        )
    }
}
