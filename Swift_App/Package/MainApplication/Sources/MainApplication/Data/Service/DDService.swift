//
//  DDService.swift
//  MainApplication
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
    func getCarApprovalOrderStatisticalMyData(dimension: Int?) async throws -> HomeServiceOrderDropdownResult? {
        return try await APISession.shared.api_carApprovalOrder_statisticalMyData(dimension: dimension)
    }
}
