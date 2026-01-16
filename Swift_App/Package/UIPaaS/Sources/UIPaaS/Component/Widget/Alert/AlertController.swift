//
//  AlertController..swift
//  
//
//  Created by wuwei on 2022/9/2.
//

import UIKit

nonisolated(unsafe)
private var buttonActionKey: Void?

@MainActor
open class AlertController: UIViewController {
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .custom
        transitioningDelegate = transition
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .custom
        transitioningDelegate = transition
    }
    
    public convenience init(title: String?, message: String?, actions: [AlertAction] = []) {
        self.init(nibName: nil, bundle: nil)
        
        _ = {
            self.title = title
            self.message = message
            self.actions = actions
        }()
    }
    
    private var transition: CenterPresentationTransition = .init()
    
    open override var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.isHidden = !(title?.isEmpty == false)
            updateLayout()
        }
    }
    
    open var message: String? {
        didSet {
            messageLabel.text = title
            messageLabel.isHidden = !(message?.isEmpty == false)
            updateLayout()
        }
    }
    
    open var actions: [AlertAction] = [] {
        didSet {
            actionBar.actions = actions.map({ action in
                let style: ActionBarAction.Style = {
                    switch action.style {
                    case .cancel:
                        return .secondary
                    case .default:
                        return .primary
                    }
                }()
                return .init(title: action.title,
                             style: style) { [weak self] in
                    guard let self = self else {
                        return
                    }
                    self.dismiss(animated: true) {
                        action.handler?()
                    }
                }
            })
        }
    }
    
    private lazy var contentStackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .vertical
        instance.alignment = .fill
        instance.distribution = .fill
        return instance
    }()
    
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.font = .sys_16_semibold
        instance.textColor = .hex_1d1d1f
        instance.textAlignment = .center
        instance.numberOfLines = 0
        instance.isHidden = true
        return instance
    }()
    
    private lazy var messageLabel: UILabel = {
        let instance = UILabel()
        instance.font = .sys_14
        instance.textColor = .hex_999999
        instance.textAlignment = .left
        instance.numberOfLines = 0
        instance.isHidden = true
        return instance
    }()
    
    private lazy var actionBar: ActionBar = {
        let instance = ActionBar()
        return instance
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        
        view.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                                     contentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                                     contentStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
                                     contentStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
        
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(messageLabel)
        contentStackView.addArrangedSubview(actionBar)
        actionBar.directionalLayoutMargins = .init(top: 0, leading: 0, bottom: 16, trailing: 0)
        
        updateLayout()
    }
    
    private func updateLayout() {
        if let title = title, !title.isEmpty, let message = message, !message.isEmpty {
            contentStackView.setCustomSpacing(16, after: titleLabel)
            contentStackView.setCustomSpacing(20, after: messageLabel)
        } else if let title = title, !title.isEmpty {
            contentStackView.setCustomSpacing(30, after: titleLabel)
        }
    }
}
