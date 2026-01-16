//
//  FormRuleError.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/30.
//

import Foundation

public struct FormRuleError: LocalizedError {
    public var message: String?
    
    public init(message: String? = nil) {
        self.message = message
    }
    
    public var errorDescription: String? {
        return message
    }
}

extension FormRuleError {
    public static let requirement: FormRuleError = .init(message: "内容不能为空")
}
