//
//  FinnhubPriceDataProvider.swift
//  TotalApp
//
//  Created by Rafal Bereski on 16/06/2025.
//

import Foundation

public class FinnhubFinanceDataProvider : PriceDataProviderType {
    private let baseUrl = URL(string: "https://finnhub.io/api/v1/quote")!
    public let id: PriceDataProviderID = .finnhub
    private let currency: Currency = .usd
    private var apiKey: String = ""
    private let rateLimitter = RateLimiter(maxRequests: 45, interval: 60.0)
    private let session: URLSession

    public init() {
        let config = URLSessionConfiguration.ephemeral
        config.httpShouldSetCookies = false
        config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: config)
    }

    public func configure(with configManager: ConfigManager) async throws(DataProviderError) {
        guard let apiKey = await configManager.getAPIKey(forProvider: .finnhub)?.key else {
            throw DataProviderError.missingAPIKey(provider: id.providerName)
        }
        self.apiKey = apiKey
    }
    
    public func fetchPrice(symbol: String) async throws(DataProviderError) -> AssetPrice {
        await rateLimitter.waitIfNeed()
        
        let components =  URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
        let (data, response): (Data, URLResponse)
        let json: [String: Any]
        
        guard let url = components.with({ $0.queryItems = [
            .init(name: "symbol", value: symbol.uppercased()),
            .init(name: "token", value: apiKey)
        ]}).url else {
            throw requestError("Cannot create request URL.")
        }
    
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw requestError("Cannot fetch data from the price provider.")
        }
        
        if (response as? HTTPURLResponse)?.statusCode == 401 {
            throw .incorrectAPIKey(provider: id.providerName)
        }
        
        if (response as? HTTPURLResponse)?.statusCode == 400 {
            throw invalidSymbol(symbol)
        }
        
        do {
            json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
        } catch {
            throw requestError("Cannot parse JSON data.")
        }
        
        guard let price = json["c"] as? Double else {
            throw requestError("Unexpected response format.")
        }
        
        return .init(
            symbol: symbol,
            price: price,
            currency: currency,
            timestamp: Timestamp.current
        )
    }
}
