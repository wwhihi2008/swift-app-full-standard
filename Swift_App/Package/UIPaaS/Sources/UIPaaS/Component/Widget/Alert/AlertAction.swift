//
//  AlertAction.swift
//  
//
//  Created by wuwei on 2022/9/5.
//

import UIKit

open class AlertAction {
    public init(title: String, style: Style, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    open var title: String
    open var style: Style
    open var handler: (() -> Void)?
}

extension AlertAction {
    public enum Style {
        case `default`
        case cancel
    }
}

extension AlertAction {
    public convenience init(confirmHandler: (() -> Void)? = nil) {
        self.init(title: "确认", style: .default, handler: confirmHandler)
    }
    
    public convenience init(cancelHandler: (() -> Void)? = nil) {
        self.init(title: "再想想", style: .cancel, handler: cancelHandler)
    }
}
