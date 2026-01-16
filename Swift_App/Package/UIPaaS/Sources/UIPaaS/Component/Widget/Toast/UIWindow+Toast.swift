//
//  UIWindow+Toast.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/20.
//

import UIKit

nonisolated(unsafe)
private var toastViewKey: Void?

@MainActor
extension UIWindow {
    private var toastView: ToastView? {
        get {
            return objc_getAssociatedObject(self, &toastViewKey) as? ToastView
        }
        set {
            objc_setAssociatedObject(self, &toastViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func toast(_ text: String?,
                      delay: TimeInterval = 0,
                      showDuration: TimeInterval = 0.25,
                      keepDuration: TimeInterval = 2,
                      hideDuration: TimeInterval = 0,
                      completionHandler: (() -> Void)? = nil) {
        toastView?.removeFromSuperview()
        
        let newToastView = ToastView()
        newToastView.text = text
        addSubview(newToastView)
        newToastView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([newToastView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
                                     newToastView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
                                     newToastView.leadingAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor, constant: 40),
                                     newToastView.trailingAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor, constant: -40),
                                     newToastView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 60),
                                     newToastView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: 60)])
        UIView.animate(withDuration: showDuration, delay: delay) {
            newToastView.alpha = 1
        } completion: { _ in
            UIView.animate(withDuration: hideDuration, delay: keepDuration) {
                newToastView.alpha = 0
            } completion: { _ in
                newToastView.removeFromSuperview()
                completionHandler?()
            }
        }
        toastView = newToastView
    }
}
