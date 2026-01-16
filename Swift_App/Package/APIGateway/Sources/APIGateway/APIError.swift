//
//  APIError.swift
//  APIGateway
//
//  Created by wuwei on 2025/6/13.
//

import Foundation

public enum APIError: Error {
    /// 响应错误
    case unexpectedResponse(response: URLResponse?)
    /// 业务错误
    case bizCode(code: Int, message: String?)
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unexpectedResponse(let response):
            return "unexpected resonse"
        case .bizCode(let code, let message):
            return message ?? ""
        }
    }
}
