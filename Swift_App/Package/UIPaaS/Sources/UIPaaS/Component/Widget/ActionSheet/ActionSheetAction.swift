//
//  ActionSheetAction.swift
//  
//
//  Created by wuwei on 2022/9/8.
//

import UIKit

@MainActor
open class ActionSheetAction {
    public init(title: String, style: Style, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    open var title: String
    open var style: Style
    open var handler: (() -> Void)?
}

extension ActionSheetAction {
    public enum Style {
        case `default`
        case cancel
    }
}
