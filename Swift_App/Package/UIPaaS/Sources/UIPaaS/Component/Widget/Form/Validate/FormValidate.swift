//
//  FormValidate.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/15.
//

@MainActor
public protocol FormContentValidation {
    associatedtype ValueType
    var contentRules: [FormRule<ValueType>] { get }
    func validateContent() async -> Bool
}


@MainActor
public protocol FormRequirementValidation {
    associatedtype ValueType
    var requirementRule: FormRule<ValueType>? { get }
    func validateRequirement() async -> Bool
}
