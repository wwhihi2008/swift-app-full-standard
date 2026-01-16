//
//  UIButton+Throttle.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/23.
//

import UIKit

nonisolated(unsafe)
private var throttleKey: Void?

@MainActor
extension UIButton {
    public var throttle: Bool {
        get {
            return (objc_getAssociatedObject(self, &throttleKey) as? Bool) ?? false
        }
        set {
            objc_setAssociatedObject(self, &throttleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue {
                addTarget(self, action: #selector(self.throttleAction), for: .touchUpInside)
            } else {
                removeTarget(self, action: #selector(self.throttleAction), for: .touchUpInside)
            }
        }
    }
    
    /// 节流
    @objc
    private func throttleAction(sender: UIButton) {
        sender.isUserInteractionEnabled = false
        Task {
            try await Task.sleep(nanoseconds: UInt64(0.3 * 1000 * 1000 * 1000))
            sender.isUserInteractionEnabled = true
        }
    }
}
