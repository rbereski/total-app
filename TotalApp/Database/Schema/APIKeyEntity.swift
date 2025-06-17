//
//  APIKeyEntity.swift
//  TotalApp
//
//  Created by Rafal Bereski on 22/05/2025.
//

import SwiftData

@Model
public class APIKeyEntity {
    public var id: String
    public var key: String
    public private(set) var _provider: String
    
    public var provider: APIProvider {
        .init(rawValue: _provider) ?? .unspecified
    }
    
    public init(id: String, key: String, provider: APIProvider) {
        self.id = id
        self.key = key
        self._provider = provider.rawValue
    }
    
    public convenience init(from apiKey: APIKey) {
        self.init(id: apiKey.id, key: apiKey.key, provider: apiKey.provider)
    }
    
    public func applyChanges(_ model: APIKey) {
        self.id = model.id
        self.key = model.key
        self._provider = model.provider.rawValue
    }
}

public extension APIKey {
    convenience init(from entity: APIKeyEntity) {
        self.init(
            id: entity.id,
            key: entity.key,
            provider: entity.provider,
            persistentId: entity.persistentModelID
        )
    }
}
