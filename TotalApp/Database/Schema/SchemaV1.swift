//
//  SchemaV1.swift
//  TotalApp
//
//  Created by Rafal Bereski on 12/06/2025.
//

import SwiftData

enum SchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [
            AssetEntity.self,
            AssetValueEntity.self,
            CategoryValueEntity.self,
            TotalValueEntity.self,
            SnapshotsConfigEntity.self,
            APIKeyEntity.self
        ]
    }
}
