//
//  APIKey.swift
//  TotalApp
//
//  Created by Rafal Bereski on 22/05/2025.
//

import SwiftData

@Observable
public class APIKey: PersistentModelType, Identifiable {
    public var id: String
    public var key: String
    public var provider: APIProvider
    public var persistentId: PersistentIdentifier?
    
    public init(
        id: String = "",
        key: String = "",
        provider: APIProvider = .unspecified,
        persistentId: PersistentIdentifier? = nil
    ) {
        self.id = id
        self.provider = provider
        self.key = key
        self.persistentId = persistentId
    }
    
    public convenience init(apiKey: APIKey) {
        self.init(
            id: apiKey.id,
            key: apiKey.key,
            provider: apiKey.provider,
            persistentId: apiKey.persistentId
        )
    }
    
    public convenience init(apiProvider: APIProvider) {
        self.init(id: apiProvider.defaultKeyId, provider: apiProvider)
    }
    
    public var isNew: Bool {
        persistentId == nil
    }
}
