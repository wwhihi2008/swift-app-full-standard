//
//  Directive.swift
//  Directive
//
//  Created by wuwei on 2025/6/16.
//

import Foundation

open class Directive: @unchecked Sendable {
    open var code: String?
    open var params: [AnyHashable: Any]?
    
    public init(code: String? = nil, params: [AnyHashable : Any]? = nil) {
        self.code = code
        self.params = params
    }
}

extension Directive {
    public static let remoteNotification: Notification.Name = .init(rawValue: "directive_remote")
    public static let directiveNoticationKey: String = "directive"
}
