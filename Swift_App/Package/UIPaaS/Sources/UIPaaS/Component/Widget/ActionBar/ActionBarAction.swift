//
//  ActionBarAction.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/10.
//

import UIKit

@MainActor
open class ActionBarAction: @unchecked Sendable {
    public enum Style: Int {
        case primary = 1
        case secondary = 2
    }
    
    open var title: String?
    open var style: Style
    open var handler: (() -> Void)?
    
    public init(title: String? = nil, style: Style, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}
