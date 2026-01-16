//
//  UIView+Loading.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/20.
//

import UIKit

nonisolated(unsafe)
private var loadingViewKey: Void?

@MainActor
extension UIView {
    private var loadingView: LoadingView {
        if let instance = objc_getAssociatedObject(self, &loadingViewKey) as? LoadingView {
            return instance
        } else {
            let instance = LoadingView()
            objc_setAssociatedObject(self, &loadingViewKey, instance, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return instance
        }
    }
    
    public func beginLoading() {
        let loadingView = self.loadingView
        addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([loadingView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     loadingView.trailingAnchor.constraint(equalTo: trailingAnchor),
                                     loadingView.topAnchor.constraint(equalTo: topAnchor),
                                     loadingView.bottomAnchor.constraint(equalTo: bottomAnchor)])
        loadingView.startAnimating()
    }
    
    public func endLoading() {
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
    }
}
