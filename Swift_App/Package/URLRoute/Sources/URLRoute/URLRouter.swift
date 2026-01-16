//
//  URLRouter.swift
//  URLRoute
//
//  Created by wuwei on 2025/6/25.
//

import Foundation

@MainActor
open class URLRouter: RouteNode {
    public static let shared: URLRouter = .init()
    
    open var nodes: [RouteNode] = []
    
    public func route(for url: URL) -> URLRoute? {
        for node in nodes {
            if let response = node.route(for: url) {
                return response
            }
        }
        return nil
    }
}
