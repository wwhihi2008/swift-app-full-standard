//
//  FooterRefreshControl.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/23.
//

import UIKit

public enum FooterRefreshControlStatus {
    case idle
    case refreshing
    case complete
}

@MainActor
open class FooterRefreshControl: RefreshControl {
    open var refreshingText: String? = "刷新中"
    open var completionText: String? = "我也是有底线的～"
    
    open private(set) var status: FooterRefreshControlStatus = .idle {
        didSet {
            switch status {
            case .idle:
                indicatorView.isHidden = false
                indicatorView.stopAnimating()
                textLabel.isHidden = true
                textLabel.text = nil
            case .refreshing:
                indicatorView.isHidden = false
                indicatorView.startAnimating()
                textLabel.isHidden = false
                textLabel.text = refreshingText
            case .complete:
                indicatorView.isHidden = true
                indicatorView.stopAnimating()
                textLabel.isHidden = false
                textLabel.text = completionText
            }
        }
    }
    
    open var didBeginRefreshingHandler: (() -> Void)?
    
    open func beginRefreshing() {
        guard status == .idle else {
            return
        }
        status = .refreshing
        didBeginRefreshingHandler?()
    }

    open func endRefreshing() {
        guard status == .refreshing else {
            return
        }
        status = .idle
    }
    
    open func complete() {
        status = .complete
    }
    
    open func reset() {
        status = .idle
    }
    
    private var kvoObservers: [NSKeyValueObservation] = []
    
    open override func didMoveToSuperview() {
        guard let scrollView = superview as? UIScrollView else {
            kvoObservers.removeAll()
            return
        }
        
        kvoObservers.append(scrollView.observe(\.contentOffset, options: [.new]) { [weak self, weak scrollView] _, value in
            guard let self = self, let scrollView = scrollView else {
                return
            }
            Task { @MainActor in
                self.contentOffsetDidChange(scrollView: scrollView)
            }
        })
        kvoObservers.append(scrollView.observe(\.contentSize, options: [.new], changeHandler: { [weak self, weak scrollView] _, value in
            guard let self = self, let scrollView = scrollView else {
                return
            }
            Task { @MainActor in
                self.contentSizeDidChange(scrollView: scrollView)
            }
        }))
        contentOffsetDidChange(scrollView: scrollView)
        contentSizeDidChange(scrollView: scrollView)
    }
    
    private func contentOffsetDidChange(scrollView: UIScrollView) {
        guard status == .idle, !isHidden else {
            return
        }
        
        // 头部刷新时，不触发底部刷新
        if scrollView.headerRefreshControl?.isRefreshing == true {
            return
        }

        // 底部刷新器可见时触发刷新
        if scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.adjustedContentInset.top) < scrollView.frame.size.height - 1 {
            beginRefreshing()
        }
    }
    
    private func contentSizeDidChange(scrollView: UIScrollView) {
        // tableView的contentLayoutGuide.bottom不生效，因此使用frame来计算位置
        frame = .init(x: 0, y: scrollView.contentSize.height, width: scrollView.frame.size.width, height: FooterRefreshControl.defaultHeight)
        
        if status == .complete && (scrollView.contentSize.height < scrollView.frame.size.height + 1) {
            scrollView.contentInset = .init(top: scrollView.contentInset.top,
                                            left: scrollView.contentInset.left,
                                            bottom: 0,
                                            right: scrollView.contentInset.right)
            isHidden = true
        } else {
            scrollView.contentInset = .init(top: scrollView.contentInset.top,
                                            left: scrollView.contentInset.left,
                                            bottom: FooterRefreshControl.defaultHeight,
                                            right: scrollView.contentInset.right)
            isHidden = false
        }
    }
}

extension FooterRefreshControl {
    public static let defaultHeight: CGFloat = 44
}

nonisolated(unsafe)
private var footerRefreshControlKey: Void?

@MainActor
extension UIScrollView {
    public var footerRefreshControl: FooterRefreshControl? {
        get {
            return objc_getAssociatedObject(self, &footerRefreshControlKey) as? FooterRefreshControl
        }
        set {
            objc_setAssociatedObject(self, &footerRefreshControlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            footerRefreshControl?.removeFromSuperview()
            
            guard let newValue = newValue else {
                return
            }
            addSubview(newValue)
        }
    }
}
