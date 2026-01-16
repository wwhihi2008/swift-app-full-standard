//
//  CenterPresentationTransition.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/17.
//

import UIKit

@MainActor
open class CenterPresentationTransition: NSObject, UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationTransition()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissalTransition()
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }
}

extension CenterPresentationTransition {
    private class PresentationController: UIPresentationController {
        override func presentationTransitionWillBegin() {
            guard let containerView = containerView, let presentedView = presentedView else {
                return
            }
            containerView.addSubview(presentedView)
            presentedView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([presentedView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                                         presentedView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                                         presentedView.widthAnchor.constraint(equalToConstant: 280)])
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
                containerView.backgroundColor = .mask
            })
        }
        
        override func dismissalTransitionWillBegin() {
            guard let containerView = containerView else {
                return
            }
            presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
                containerView.backgroundColor = nil
            })
        }
    }
    
    private class PresentationTransition: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.25
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let presentedView = transitionContext.view(forKey: .to) else {
                return
            }
            presentedView.transform = presentedView.transform.scaledBy(x: 0, y: 0)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
                presentedView.transform = .identity
            } completion: { completed in
                transitionContext.completeTransition(completed)
            }
        }
    }
    
    private class DismissalTransition: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.25
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let presentedView = transitionContext.view(forKey: .from) else {
                return
            }
            UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
                // scale为0效果为直接消失，不为0效果为缩小效果
                presentedView.transform = presentedView.transform.scaledBy(x: 0, y: 0)
            } completion: { completed in
                transitionContext.completeTransition(completed)
            }
        }
    }
}
