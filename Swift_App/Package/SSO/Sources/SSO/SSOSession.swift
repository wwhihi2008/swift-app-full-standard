//
//  SSOSession.swift
//  SSO
//
//  Created by wuwei on 2025/6/30.
//

import Foundation
import CryptoKit
import APIGateway

@MainActor
open class SSOSession: @unchecked Sendable {
    public static let shared: SSOSession = .init()
    
    private let tokenKey = "token"
    
    init() {
        self.token = UserDefaults.standard.string(forKey: tokenKey)
    }
    
    open var deviceId: String?
    
    open var token: String? {
        didSet {
            UserDefaults.standard.setValue(token, forKey: tokenKey)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: Self.tokenDidUpdateNotification, object: self)
        }
    }
    
    open func login(username: String?,
                    password: String?) async throws -> String? {
        let md5edPassword = password?.data(using: .utf8).flatMap { data in
            let digest = Insecure.MD5.hash(data: data)
            let string = digest.map { int8 in
                return String(format: "%02hhx", int8)
            }.joined()
            return string
        }
        let newToken = try await APISession.shared.api_auth_login(username: username, password: md5edPassword)
        Task {
            token = newToken
        }
        return newToken
    }
    
    open func logout() async throws {
        Task {
            token = nil
        }
        try await APISession.shared.api_logout(deviceId: deviceId)
    }
}

extension SSOSession {
    public static let tokenDidUpdateNotification: Notification.Name = .init(rawValue: "sso_tokenDidUpdate")
}
