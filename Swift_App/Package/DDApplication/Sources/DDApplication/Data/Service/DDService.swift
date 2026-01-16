//
//  DDService.swift
//  DDApplication
//
//  Created by wuwei on 2025/6/26.
//

import UIKit
import APIGateway

@MainActor
class DDService: @unchecked Sendable {
    static let shared: DDService = .init()
}

extension DDService {
    func getServiceOrderList(query: PageQuery, dimension: Int?) async throws -> PageResult<ServiceOrderListItem>? {
        return try await APISession.shared.api_carApprovalOrder_listForApp(query: query, dimension: dimension)
    }
}
