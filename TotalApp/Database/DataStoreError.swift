//
//  DataError.swift
//  TotalApp
//
//  Created by Rafal Bereski on 11/05/2025.
//

import Foundation

public enum DataStoreError: LocalizedError {
    case initError(_ msg: String, innerError: Error? = nil)
    case assetError(_ msg: String, innerError: Error? = nil)
    case snapshotError(_ msg: String, innerError: Error? = nil)
    case configError(_ msg: String, innerError: Error? = nil)
    case apiKeysError(_ msg: String, innerError: Error? = nil)
    
    public var errorDescription: String? {
        switch self {
            case .initError(let msg, _): return msg
            case .assetError(let msg, _): return msg
            case .snapshotError(let msg, _): return msg
            case .configError(let msg, _): return msg
            case .apiKeysError(let msg, _): return msg
        }
    }
    
    public var failureReason: String? {
        return "Data Store Error"
    }
}
