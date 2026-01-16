//
//  RouteNode.swift
//  URLRoute
//
//  Created by wuwei on 2025/6/25.
//

import Foundation

@MainActor
public protocol RouteNode {
    func route(for url: URL) -> URLRoute?
}
