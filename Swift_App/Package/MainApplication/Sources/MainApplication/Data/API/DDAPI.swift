//
//  DDAPI..swift
//  MainApplication
//
//  Created by wuwei on 2025/6/25.
//

import Foundation
import APIGateway

extension APISession {    
    func api_carApprovalOrder_statisticalMyData(dimension: Int?) async throws -> HomeServiceOrderDropdownResult? {
        struct RequestData: Codable {
            var dimension: Int?
        }
        let data: RequestData = .init(dimension: dimension)
        
        return try await post(path: "/mob/carApprovalOrder/statisticalMyData", data: data)
    }
}
