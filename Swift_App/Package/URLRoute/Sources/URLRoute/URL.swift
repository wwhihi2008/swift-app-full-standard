//
//  URL.swift
//  URLRoute
//
//  Created by wuwei on 2025/6/25.
//

import Foundation

extension URL {
    public static let appBaseURL: Self = .init(string: "app://local")!
    
    public var isAppURL: Bool {
        return scheme == "app" && host == "local"
    }
}
