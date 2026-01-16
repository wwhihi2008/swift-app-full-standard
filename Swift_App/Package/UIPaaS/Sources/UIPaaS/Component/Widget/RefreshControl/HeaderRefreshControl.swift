//
//  HeaderRefreshControl.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/23.
//

import UIKit

@MainActor
open class HeaderRefreshControl: RefreshControl {
    open var refreshingText: String? = "刷新中"
    
    open var isRefreshing: Bool = false {
        didSet {
            if isRefreshing {
                indicatorView.startAnimating()
                textLabel.isHidden = false
                textLabel.text = refreshingText
            } else {
                indicatorView.stopAnimating()
                textLabel.isHidden = true
                textLabel.text = nil
            }
        }
    }
    
    open var didBeginRefreshingHandler: (() -> Void)?
    
    open func beginRefreshing() {
        isRefreshing = true
        didBeginRefreshingHandler?()
    }
    
    open func simulateRefreshing() {
        guard !isRefreshing, let scrollView = superview as? UIScrollView else {
            return
        }
        UIView.animate(withDuration: 0.25) {
            scrollView.contentInset = .init(top: self.bounds.height,
                                            left: scrollView.contentInset.left,
                                            bottom: scrollView.contentInset.bottom,
                                            right: scrollView.contentInset.right)
            scrollView.contentOffset = .init(x: scrollView.contentOffset.x,
                                             y: -self.bounds.height)
        } completion: { _ in
            self.beginRefreshing()
        }
    }
    
    open func endRefreshing() {
        isRefreshing = false
        didEndRefreshing()
    }
    
    private func didEndRefreshing() {
        guard let scrollView = superview as? UIScrollView else {
            return
        }
        UIView.animate(withDuration: 0.25) {
            scrollView.contentInset = .init(top: 0,
                                            left: scrollView.contentInset.left,
                                            bottom: scrollView.contentInset.bottom,
                                            right: scrollView.contentInset.right)
            scrollView.contentOffset = .init(x: scrollView.contentOffset.x,
                                             y: 0)
        }
    }
    
    private var contentOffsetObserver: NSKeyValueObservation?
    
    open override func didMoveToSuperview() {
        guard let scrollView = superview as? UIScrollView else {
            contentOffsetObserver = nil
            return
        }
        contentOffsetObserver = scrollView.observe(\.contentOffset, options: .new) { [weak self, weak scrollView] _, value in
            guard let self = self, let scrollView = scrollView else {
                return
            }
            Task { @MainActor in
                self.contentOffsetDidChange(scrollView: scrollView)
            }
        }
        contentOffsetDidChange(scrollView: scrollView)
    }
    
    private func contentOffsetDidChange(scrollView: UIScrollView) {
        if !isRefreshing, !isHidden, !scrollView.isDragging, scrollView.contentOffset.y + scrollView.adjustedContentInset.top < -bounds.height {
            beginRefreshing()
            UIView.animate(withDuration: 0.25) {
                scrollView.contentInset = .init(top: self.bounds.height,
                                                left: scrollView.contentInset.left,
                                                bottom: scrollView.contentInset.bottom,
                                                right: scrollView.contentInset.right)
                scrollView.contentOffset = .init(x: scrollView.contentOffset.x,
                                                 y: -self.bounds.height)
            } completion: { _ in
                
            }
        }
    }
}

extension HeaderRefreshControl {
    public static let defaultHeight: CGFloat = 44
}

nonisolated(unsafe)
private var headerRefreshControlKey: Void?

@MainActor
extension UIScrollView {
    public var headerRefreshControl: HeaderRefreshControl? {
        get {
            return objc_getAssociatedObject(self, &headerRefreshControlKey) as? HeaderRefreshControl
        }
        set {
            objc_setAssociatedObject(self, &headerRefreshControlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            headerRefreshControl?.removeFromSuperview()
            
            guard let newValue = newValue else {
                return
            }
            addSubview(newValue)
            newValue.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([newValue.leadingAnchor.constraint(equalTo: frameLayoutGuide.leadingAnchor),
                                         newValue.trailingAnchor.constraint(equalTo: frameLayoutGuide.trailingAnchor),
                                         newValue.bottomAnchor.constraint(equalTo: contentLayoutGuide.topAnchor),
                                         newValue.heightAnchor.constraint(equalToConstant: HeaderRefreshControl.defaultHeight)])
        }
    }
}
