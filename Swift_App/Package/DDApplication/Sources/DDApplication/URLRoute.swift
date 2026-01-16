//
//  URLRoute.swift
//  DDApplication
//
//  Created by wuwei on 2025/6/26.
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
        case "/approvalOrderList":
            return .init(viewController: ApprovalOrderListViewController())
        default:
            return nil
        }
    }
}
