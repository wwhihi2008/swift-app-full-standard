//
//  LoadingView.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/20.
//

import UIKit

@MainActor
open class LoadingView: UIView {
    private lazy var indicatorView: UIActivityIndicatorView = {
        let instance = UIActivityIndicatorView()
        instance.color = .hex_999999
        instance.transform = .init(scaleX: 1.5, y: 1.5)
        return instance
    }()
    
    public func startAnimating() {
        addSubview(indicatorView)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        if superview?.next is UIViewController {
            NSLayoutConstraint.activate([indicatorView.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
                                         indicatorView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)])
        } else {
            NSLayoutConstraint.activate([indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
                                         indicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)])
        }
        indicatorView.isHidden = true
        Task {
            try await Task.sleep(nanoseconds: 500 * 1000 * 1000)
            indicatorView.isHidden = false
            indicatorView.startAnimating()
        }
    }
    
    public func stopAnimating() {
        indicatorView.stopAnimating()
        indicatorView.removeFromSuperview()
    }
}
