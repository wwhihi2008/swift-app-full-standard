//
//  URLRoute.swift
//  AuthApplication
//
//  Created by wuwei on 2025/6/25.
//

import Foundation
import URLRoute

extension Application: RouteNode {
    public func route(for url: URL) -> URLRoute? {
        guard url.isAppURL else {
            return nil
        }
        let path = url.path()
        switch path {
        case "/login":
            return .init(viewController: LoginViewController())
        default:
            return nil
        }
    }
}
