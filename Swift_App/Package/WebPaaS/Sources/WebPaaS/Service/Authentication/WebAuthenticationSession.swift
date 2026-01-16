//
//  WebAuthenticationSession.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/7.
//

import Foundation

@MainActor
public protocol WebAuthenticationSessionDelegate: NSObjectProtocol {
    func webAuthenticationSessionShouldLogin(_ session: WebAuthenticationSession)
    func webAuthenticationSessionShouldLogout(_ session: WebAuthenticationSession)
}

@MainActor
open class WebAuthenticationSession {
    public init() { }

    open var token: String?
        
    open weak var delegate: WebAuthenticationSessionDelegate?
    
    open func login() async throws -> String? {
        if let token = token {
            return token
        } else {
            delegate?.webAuthenticationSessionShouldLogin(self)
            return nil
        }
    }
    
    open func logout() {
        delegate?.webAuthenticationSessionShouldLogout(self)
    }
}
