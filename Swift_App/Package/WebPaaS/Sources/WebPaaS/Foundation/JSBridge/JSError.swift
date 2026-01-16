//
//  JSError.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/7.
//

import Foundation

public struct JSError: LocalizedError {
    public var code: Int
    public var message: String
    
    public var errorDescription: String? {
        return message
    }
}

extension JSError {
    public static let webviewNotFound: Self = .init(code: 1, message: "webview not found")
    
    public static func underlyingError(_ error: Error) -> Self {
        return .init(code: 10000, message: error.localizedDescription)
    }
    
    public static let nativeBridgeNotFound: Self = .init(code: 10001, message: "bridge not found")
    public static let nativeModuleNotFound: Self = .init(code: 10002, message: "module not found")
    public static let nativeAPINotFound: Self = .init(code: 10003, message: "API not found")
}
