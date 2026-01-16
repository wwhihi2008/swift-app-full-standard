//
//  ScrollViewKeyboardAdapter.swift
//  
//
//  Created by wuwei on 2022/12/19.
//

import UIKit

/// 点击ScrollView中控件弹起键盘时，自动调整ScrollView的contentInset和contentOffset，使得控件位置在键盘之上，ScrollView可以滑动到顶部和底部
@MainActor
open class ScrollViewKeyboardAdapter {
    public init(responderView: UIScrollView, offsetY: CGFloat = 0) {
        self.responderView = responderView
        self.offsetY = offsetY
    }

    public let responderView: UIScrollView
    public var offsetY: CGFloat
    public var contentInsetAnchor: UIEdgeInsets = .zero
    
    private var tasks: [Task<Void, Never>] = []
    
    open func start() {
        let keyboardWillShowTask = Task { [weak self] in
            let keyboardWillShowNotifications = NotificationCenter.default.notifications(named: UIResponder.keyboardWillShowNotification)
            let keyboardWillShowSequence = keyboardWillShowNotifications.compactMap({ no in
                if let keyboardInfo = no.userInfo,
                   let endFrame = keyboardInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                   let animationDuration = keyboardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                    return (endFrame, animationDuration)
                }
                return nil
            })
            for await (endFrame, animationDuration) in keyboardWillShowSequence {
                guard let self = self, UIApplication.shared.applicationState == .active, let responder = self.getFirstResponderOf(view: self.responderView) else {
                    return
                }
                let responderBoundsInWindow = responder.convert(responder.bounds, to: self.responderView.window)
                let keyboardYInWindow: CGFloat = endFrame.minY - (responder.inputView?.bounds.height ?? 0)
                if keyboardYInWindow - self.offsetY < responderBoundsInWindow.maxY, let responderWindow = self.responderView.window, let superView = self.responderView.superview {
                    let responderViewBottomPointInWindow = superView.convert(.init(x: 0, y: self.responderView.frame.maxY), to: responderWindow).y
                    let contentOffsetY = responderBoundsInWindow.maxY - keyboardYInWindow + self.offsetY
                    UIView.animate(withDuration: animationDuration) {
                        // 区分一下contentSize是否小于frame的情况，这种情况下contentInset不宜偏移太大，否则容易出现响应控件被推到顶部产生不好的交互效果
                        self.responderView.contentInset = .init(top: self.contentInsetAnchor.top,
                                                                left:  self.contentInsetAnchor.left,
                                                                bottom: self.responderView.contentSize.height > self.responderView.frame.size.height ? self.contentInsetAnchor.bottom + endFrame.size.height - (responderWindow.bounds.size.height - responderViewBottomPointInWindow) : self.contentInsetAnchor.bottom + contentOffsetY,
                                                                right:  self.contentInsetAnchor.right)
                        self.responderView.contentOffset = .init(x: self.responderView.contentOffset.x,
                                                                 y: self.responderView.contentOffset.y + contentOffsetY)
                    }
                }
            }
        }
        tasks.append(keyboardWillShowTask)
        
        let keyboardWillHideTask = Task { [weak self] in
            let keyboardWillHideNotifications = NotificationCenter.default.notifications(named: UIResponder.keyboardWillHideNotification)
            let keyboardWillHideSequence = keyboardWillHideNotifications.compactMap({ no in
                if let keyboardInfo = no.userInfo,
                   let animationDuration = keyboardInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double {
                    return animationDuration
                }
                return nil
            })
            for await animationDuration in keyboardWillHideSequence {
                guard let self = self, UIApplication.shared.applicationState == .active else {
                    return
                }
                UIView.animate(withDuration: animationDuration) {
                    self.responderView.contentInset = self.contentInsetAnchor
                }
            }
        }
        tasks.append(keyboardWillHideTask)
    }

    open func stop() {
        tasks.forEach { task in
            task.cancel()
        }
        tasks.removeAll()
        // 这里要主动复原位置，避免键盘弹起时取消监听造成键盘收回后可能出现的位置偏移
        self.responderView.transform = .identity
    }

    private func getFirstResponderOf(view: UIView) -> UIView? {
        if view.isFirstResponder {
            return view
        } else {
            return view.subviews.compactMap { subview in
                return self.getFirstResponderOf(view: subview)
            }.first
        }
    }
}
