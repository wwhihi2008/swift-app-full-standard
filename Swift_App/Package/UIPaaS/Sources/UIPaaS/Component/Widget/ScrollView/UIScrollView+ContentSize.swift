//
//  UIScrollView+ContentSize.swift
//  UIPaaS
//
//  Created by wuwei on 2025/8/5.
//

import UIKit

nonisolated(unsafe)
private var contentSizeObserverKey: Void?

@MainActor
extension UIScrollView {
    public func fitContentSize() {
        if objc_getAssociatedObject(self, &contentSizeObserverKey) != nil {
            return
        }
        
        let observer = observe(\.contentSize, options: .new) { [weak self] _, value in
            Task { @MainActor in
                guard let newSize = value.newValue, let self = self else {
                    return
                }
                let heightAnchor: NSLayoutConstraint = {
                    if let constraint = self.constraints.first(where: { constraint in
                        return constraint.firstAttribute == .height
                    }) {
                        return constraint
                    }
                    let constraint = self.heightAnchor.constraint(equalToConstant: 0)
                    NSLayoutConstraint.activate([constraint])
                    return constraint
                }()
                heightAnchor.constant = newSize.height
            }
        }
        objc_setAssociatedObject(self, &contentSizeObserverKey, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
