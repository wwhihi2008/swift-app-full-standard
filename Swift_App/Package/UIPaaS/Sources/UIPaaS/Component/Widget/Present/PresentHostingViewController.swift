//
//  PresentHostingViewController.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/24.
//

import UIKit

@MainActor
open class PresentHostingViewController: UIViewController, UINavigationControllerDelegate {
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .overFullScreen
    }
    
    open var firstContentViewController: UIViewController? {
        didSet {
            if let firstContentViewController = firstContentViewController {
                containerViewController.setViewControllers([firstContentViewController], animated: false)
                Task {
                    updateContent(content: firstContentViewController)
                }
            } else {
                containerViewController.setViewControllers([], animated: false)
            }
        }
    }
    
    private lazy var containerViewController: UINavigationController = {
        let instance = UINavigationController()
        instance.delegate = self
        return instance
    }()
        
    open var autoCloseByMask: Bool = true {
        didSet {
            maskButton.isUserInteractionEnabled = autoCloseByMask
        }
    }
    
    open var closeHandler: (() -> Void)?
    
    private lazy var maskButton: UIButton = {
        let instance = UIButton(type: .custom)
        instance.backgroundColor = .mask
        instance.addTarget(self, action: #selector(self.maskButtonDidClick), for: .touchUpInside)
        return instance
    }()
    
    @objc
    private func maskButtonDidClick() {
        close()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
                
        view.addSubview(maskButton)
        maskButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([maskButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     maskButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     maskButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     maskButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2)])
        
        addChild(containerViewController)
        let containerView = containerViewController.view!
        view.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     containerView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
                                     containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        containerView.layer.cornerRadius = 16
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        updateContent(content: viewController)
    }
    
    private var containerLayoutConstraints: [NSLayoutConstraint] = []
    
    private func updateContent(content: UIViewController) {
        NSLayoutConstraint.deactivate(containerLayoutConstraints)
        let containerView = containerViewController.view!
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let contentView = content.view!
        contentView.translatesAutoresizingMaskIntoConstraints = false
        containerLayoutConstraints = [contentView.widthAnchor.constraint(equalTo: containerView.widthAnchor),
                                      contentView.heightAnchor.constraint(equalTo: containerView.heightAnchor)]
        NSLayoutConstraint.activate(containerLayoutConstraints)
        
        let closeItem = UIBarButtonItem(image: .icon(named: IconName.icon_close.rawValue, fontSize: 16, color: .hex_1d1d1f),
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(self.close))
        closeItem.tintColor = .hex_1d1d1f
        content.navigationItem.rightBarButtonItem = closeItem
    }
    
    @objc
    private func close() {
        dismiss(animated: true) {
            self.closeHandler?()
        }
    }
}
