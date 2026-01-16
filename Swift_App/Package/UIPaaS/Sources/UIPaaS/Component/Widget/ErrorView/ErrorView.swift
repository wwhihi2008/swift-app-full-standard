//
//  ErrorView.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/24.
//

import UIKit

@MainActor
open class ErrorViewAction {
    public enum Style {
        case `default`
        case cancel
    }
    
    public init(title: String?, style: Style, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    open var title: String?
    open var style: Style
    open var handler: (() -> Void)?
}

@MainActor
extension ErrorViewAction {
    public static func reloadAction() -> ErrorViewAction {
        return .init(title: "刷新", style: .default, handler: nil)
    }
}

@MainActor
open class ErrorView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    open var image: UIImage? {
        didSet {
            imageView.image = image
            imageView.isHidden = image == nil
        }
    }
    
    open var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.isHidden = title == nil
        }
    }
    
    open var message: String? {
        didSet {
            messageLabel.text = message
            messageLabel.isHidden = message == nil
        }
    }
    
    private static var buttonActionKey: Void?
    
    open var actions: [ErrorViewAction] = [] {
        didSet {
            actionsStackView.arrangedSubviews.forEach { subview in
                subview.removeFromSuperview()
            }
            actions.forEach { action in
                let button: UIButton = {
                    switch action.style {
                    case .default:
                        return .primary()
                    case .cancel:
                        return .secondary()
                    }
                }()
                button.setTitle(action.title, for: .normal)
                button.addTarget(self, action: #selector(self.actionButtonDidClick(_:)), for: .touchUpInside)
                objc_setAssociatedObject(button, &Self.buttonActionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                actionsStackView.addArrangedSubview(button)
            }
            actionsStackView.isHidden = actions.isEmpty
            NSLayoutConstraint.deactivate([actionStackViewWidthConstraint])
            if actions.count > 1 {
                actionStackViewWidthConstraint = actionsStackView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1)
            } else {
                actionStackViewWidthConstraint = actionsStackView.widthAnchor.constraint(equalToConstant: 220)
            }
            NSLayoutConstraint.activate([actionStackViewWidthConstraint])
        }
    }
    
    @objc
    private func actionButtonDidClick(_ button: UIButton) {
        if let action = objc_getAssociatedObject(button, &Self.buttonActionKey) as? ErrorViewAction {
            action.handler?()
        }
    }
    
    private lazy var contentStackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .vertical
        instance.alignment = .center
        instance.distribution = .fill
        instance.spacing = 16
        return instance
    }()
    
    private lazy var imageView: UIImageView = {
        let instance = UIImageView()
        instance.isHidden = true
        return instance
    }()
    
    private lazy var textStackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .vertical
        instance.alignment = .center
        instance.distribution = .fill
        instance.spacing = 12
        return instance
    }()
    
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .hex_1d1d1f
        instance.font = .systemFont(ofSize: 16, weight: .semibold)
        instance.textAlignment = .center
        instance.isHidden = true
        return instance
    }()
    
    private lazy var messageLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .hex_999999
        instance.font = .systemFont(ofSize: 14)
        instance.textAlignment = .center
        instance.isHidden = true
        return instance
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .horizontal
        instance.alignment = .fill
        instance.distribution = .fillEqually
        instance.spacing = 16
        instance.isHidden = true
        return instance
    }()
    
    private lazy var actionStackViewWidthConstraint: NSLayoutConstraint = {
        let instance = actionsStackView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1)
        return instance
    }()
    
    private func initViews() {
        addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
                                     contentStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
                                     contentStackView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)])
        
        contentStackView.addArrangedSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([imageView.widthAnchor.constraint(equalToConstant: 90),
                                     imageView.heightAnchor.constraint(equalToConstant: 90)])
        contentStackView.setCustomSpacing(16, after: imageView)
        
        contentStackView.addArrangedSubview(textStackView)
        textStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([textStackView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, multiplier: 1)])
        contentStackView.setCustomSpacing(20, after: textStackView)
        
        textStackView.addArrangedSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([titleLabel.widthAnchor.constraint(equalTo: textStackView.widthAnchor, multiplier: 1)])
        
        textStackView.addArrangedSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([messageLabel.widthAnchor.constraint(equalTo: textStackView.widthAnchor, multiplier: 1)])
        
        contentStackView.addArrangedSubview(actionsStackView)
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([actionStackViewWidthConstraint,
                                     actionsStackView.heightAnchor.constraint(equalToConstant: 44)])
    }
}

@MainActor
extension ErrorView {
    public static func dataError(reloadHandler: (@MainActor () -> Void)? = nil) -> ErrorView {
        let instance = ErrorView()
        instance.message = "数据错误"
        instance.image = .no_network
        let reloadAction = ErrorViewAction.reloadAction()
        reloadAction.handler = reloadHandler
        instance.actions = [reloadAction]
        return instance
    }
    
    public static func empty() -> ErrorView {
        let instance = ErrorView()
        instance.message = "暂无信息"
        instance.image = .none
        return instance
    }
}
