//
//  JSAPI+Authentication.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/11.
//

import Foundation

nonisolated(unsafe)
private var authenticationSessionKey: Void?

@MainActor
extension JSAPIBus {
    var authenticationSession: WebAuthenticationSession? {
        get {
            objc_getAssociatedObject(self, &authenticationSessionKey) as? WebAuthenticationSession
        }
        set {
            objc_setAssociatedObject(self, &authenticationSessionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc
    private func login(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let authenticationSession = self.authenticationSession else {
                throw JSError.serviceNotFound
            }
            if let token = try await authenticationSession.login() {
                return ["token": token]
            } else {
                return nil
            }
        }
    }
    
    @objc
    private func logout(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let authenticationSession = self.authenticationSession else {
                throw JSError.serviceNotFound
            }
            authenticationSession.logout()
            return nil
        }
    }
}
