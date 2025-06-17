//
//  PersistableModelType.swift
//  TotalApp
//
//  Created by Rafal Bereski on 06/05/2025.
//

protocol PersistentModelType {
    associatedtype PersistentModelIdentifier: Hashable, Identifiable, Equatable, Comparable, Codable, Sendable
    var persistentId: PersistentModelIdentifier? { get set }
}
