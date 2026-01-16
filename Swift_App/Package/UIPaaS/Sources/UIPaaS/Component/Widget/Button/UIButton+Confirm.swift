//
//  UIButton+Confirm.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/28.
//

import UIKit

nonisolated(unsafe)
private var actionBlockKey: Void?

extension UIButton {
    public func addConfirmAlertedTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        addTarget(self, action: #selector(self.buttonDidControlForConfirm), for: controlEvents)
        objc_setAssociatedObject(self, &actionBlockKey, { [weak self] in
            guard let self = self, let target = target as? NSObjectProtocol, target.responds(to: action) else {
                return
            }
            target.perform(action, with: self)
        }, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    @objc
    private func buttonDidControlForConfirm(_ sender: UIButton) {
        let actionName = title(for: .normal)
        let alert = AlertController(title: actionName,
                                    message: "确认\(actionName ?? " ")吗？",
                                    actions: [.init(cancelHandler: nil),
                                              .init(confirmHandler: {
                                                  if let actionBlock = objc_getAssociatedObject(self, &actionBlockKey) as? (() -> Void) {
                                                      actionBlock()
                                                  }
                                              })])
        responderController?.present(alert, animated: true)
    }
}
