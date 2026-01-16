//
//  UIView+Responder.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/15.
//

import UIKit

extension UIView {
    public var responderController: UIViewController? {
        var responderController: UIViewController?
        var superView: UIView? = superview
        while (responderController == nil && superView != nil) {
            if let nextResponder = superView?.next, let controller = nextResponder as? UIViewController {
                responderController = controller
            } else {
                superView = superView?.superview
            }
        }
        return responderController
    }
}
