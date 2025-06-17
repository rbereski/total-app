//
//  Extensions.swift
//  TotalApp
//
//  Created by Rafal Bereski on 08/05/2025.
//

import Foundation

public protocol Then {}
extension NSObject: Then {}
extension URLComponents: Then {}

extension Then where Self: Any {
    @inlinable
    public func with(_ block: (inout Self) throws -> Void) rethrows -> Self {
        var copy = self
        try block(&copy)
        return copy
    }
}

extension Then where Self: AnyObject {
    @inlinable
    public func then(_ block: (Self) throws -> Void) rethrows -> Self {
        try block(self)
        return self
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension Optional where Wrapped == String {
    var _bound: String? {
        get { return self }
        set { self = newValue }
    }
    public var bound: String {
        get { return _bound ?? ""  }
        set { _bound = newValue.isEmpty ? nil : newValue }
    }
}

extension ProcessInfo {
    static var isOnPreview: Bool {
       return processInfo.processName == "XCPreviewAgent"
   }
}
