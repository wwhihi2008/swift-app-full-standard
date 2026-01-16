//
//  DDAPI..swift
//  DDApplication
//
//  Created by wuwei on 2025/6/25.
//

import Foundation
import APIGateway

extension APISession {
    func api_carApprovalOrder_listForApp(query: PageQuery, dimension: Int?) async throws -> PageResult<ServiceOrderListItem>? {
        class RequestData: PageQuery, @unchecked Sendable {
            var dimension: Int?
        }
        let data: RequestData = .init()
        data.page = query.page
        data.limit = query.limit
        data.order = query.order
        data.sort = query.sort
        data.dimension = dimension
        
        return try await post(path: "/mob/carApprovalOrder/listForApp", data: data)
    }
}
