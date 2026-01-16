//
//  ActionBar.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/10.
//

import UIKit

nonisolated(unsafe)
private var buttonActionKey: Void?

@MainActor
open class ActionBar: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    private lazy var buttonsStackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .horizontal
        instance.alignment = .fill
        instance.distribution = .fillEqually
        instance.spacing = 16
        return instance
    }()
        
    open var actions: [ActionBarAction] = [] {
        didSet {
            buttonsStackView.arrangedSubviews.forEach { subview in
                subview.removeFromSuperview()
            }
            actions.forEach { action in
                let button: UIButton = {
                    switch action.style {
                    case .primary:
                        return UIButton.primary()
                    case .secondary:
                        return UIButton.secondary()
                    }
                }()
                button.setTitle(action.title, for: .normal)
                button.addTarget(self, action: #selector(self.buttonDidClick(_:)), for: .touchUpInside)
                objc_setAssociatedObject(button, &buttonActionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                buttonsStackView.addArrangedSubview(button)
            }
        }
    }
    
    @objc
    private func buttonDidClick(_ sender: UIButton) {
        if let action = objc_getAssociatedObject(sender, &buttonActionKey) as? ActionBarAction {
            action.handler?()
        }
    }
    
    private func initViews() {
        directionalLayoutMargins = .init(top: 8, leading: 16, bottom: 8, trailing: 16)
        
        addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([buttonsStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                                     buttonsStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                                     buttonsStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     buttonsStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)])
    }
    
    open override var intrinsicContentSize: CGSize {
        return .init(width: frame.size.width, height: 60)
    }
}
