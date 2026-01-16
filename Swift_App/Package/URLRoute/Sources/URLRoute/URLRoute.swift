//
//  URLRoute.swift
//  URLRoute
//
//  Created by wuwei on 2025/6/25.
//

import UIKit

@MainActor
open class URLRoute: @unchecked Sendable {
    public init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public private(set) var viewController: UIViewController
}
