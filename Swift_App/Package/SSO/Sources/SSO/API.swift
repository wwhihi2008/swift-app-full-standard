//
//  API.swift
//  SSO
//
//  Created by wuwei on 2025/6/30.
//

import Foundation
import APIGateway

extension APISession {
    func api_auth_login(username: String?,
                        password: String?) async throws -> String? {
        struct RequestData: Codable {
            var username: String?
            var password: String?
            var device: String?
        }
        let requestData: RequestData = .init(username: username, password: password, device: "APP")
        
        struct ResponseData: Codable {
            var tokenValue: String?
        }
        
        let responseData = (try await post(path: "/market/auth/login", data: requestData)) as ResponseData?
        return responseData?.tokenValue
    }
    
    func api_logout(deviceId: String?) async throws {
        _ = try await post(path: "/market/auth/logout", data: deviceId) as NoneModel?
    }
}
