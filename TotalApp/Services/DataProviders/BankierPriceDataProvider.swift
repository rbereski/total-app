//
//  BankierPriceDataProvider.swift
//  TotalApp
//
//  Created by Rafal Bereski on 07/04/2025.
//

import Foundation
import SwiftSoup

public class BankierPriceDataProvider : PriceDataProviderType {
    public let baseUrl = URL(string: "https://www.bankier.pl/inwestowanie/profile/quote.html")!
    public let id: PriceDataProviderID = .bankier
    private let currency: Currency = .pln
    private let rateLimitter = RateLimiter(maxRequests: 20, interval: 60.0)
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
        
        let symbol = symbol.uppercased()
        let components =  URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)!
        let (data, response): (Data, URLResponse)
        
        guard let url = components.with({ $0.queryItems = [.init(name: "symbol", value: symbol )] }).url else {
            throw requestError("Cannot create request URL.")
        }
        
        do {
            (data, response) = try await session.data(from: url)
        } catch {
            throw requestError("Cannot fetch data from the price provider.")
        }
        
        guard
            (response as? HTTPURLResponse)?.statusCode == 200,
            let html = String(data: data, encoding: .utf8),
            let document: Document = try? SwiftSoup.parse(html),
            let lastTradeDiv = try? document.select("#last-trade-\(symbol.uppercased())").first(),
            let priceStr = lastTradeDiv.getAttributes()?.first(where: { $0.getKey() == "data-last" })?.getValue(),
            let price = Double(priceStr)
        else {
            throw invalidSymbol(symbol)
        }
        
        return .init(symbol: symbol, price: price, currency: currency, timestamp: Timestamp.current)
    }
}
