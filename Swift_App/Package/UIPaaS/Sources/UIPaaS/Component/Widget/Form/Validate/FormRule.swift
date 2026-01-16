//
//  FormRule.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/4.
//

import Foundation

@MainActor
open class FormRule<ValueType>: @unchecked Sendable {
    public init(validator: @escaping (ValueType?) async throws -> Bool) {
        self.validator = validator
    }
    
    open var validator: ((ValueType?) async throws -> Bool)
}

@MainActor
extension FormRule {
    public static func requirement() -> FormRule<ValueType> {
        return .init (validator: { value in
            if let value = value{
                return true
            }
            throw FormRuleError.requirement
        })
    }
}

@MainActor
extension FormRule where ValueType: Collection {
    public static func requirement() -> FormRule<ValueType> {
        return .init (validator: { value in
            if let value = value, !value.isEmpty {
                return true
            }
            throw FormRuleError.requirement
        })
    }
}

@MainActor
extension FormRule where ValueType == String {
    public static func predicate(_ pattern: String, errorMessage: String?) -> FormRule<ValueType> {
        return .init { value in
            let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
            if !predicate.evaluate(with: value) {
                throw FormRuleError(message: errorMessage)
            }
            return true
        }
    }
}

@MainActor
extension FormRule where ValueType == String {
    public static func maxWords(limit: UInt) -> FormRule<ValueType> {
        return .init { value in
            if let count = value?.count, count > limit {
                throw FormRuleError(message: "最多输入\(limit)字")
            }
            return true
        }
    }
}
