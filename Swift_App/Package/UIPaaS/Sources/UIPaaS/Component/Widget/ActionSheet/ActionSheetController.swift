//
//  ActionSheetController.swift
//  
//
//  Created by wuwei on 2022/9/8.
//

import UIKit

nonisolated(unsafe)
private var buttonActionKey: Void?

@MainActor
open class ActionSheetController: UIViewController {
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .overFullScreen
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        modalPresentationStyle = .overFullScreen
    }
    
    public convenience init(title: String?, actions: [ActionSheetAction] = []) {
        self.init(nibName: nil, bundle: nil)
        
        _ = {
            self.title = title
            self.actions = actions
        }()
    }
    
    open override var title: String? {
        didSet {
            titleLabel.text = title
            titleLabel.isHidden = !(title?.isEmpty == false)
        }
    }
    
    open var actions: [ActionSheetAction] = [] {
        didSet {
            defaultActionButtons.forEach { button in
                button.removeFromSuperview()
            }
            defaultActionButtons.removeAll()
            cancelStackView.arrangedSubviews.forEach { subview in
                subview.removeFromSuperview()
            }
            cancelStackView.isHidden = true
            
            actions.forEach { action in
                switch action.style {
                case .default:
                    let button = defaultActionButton()
                    button.setTitle(action.title, for: .normal)
                    button.addTarget(self, action: #selector(self.didSelectAction), for: .touchUpInside)
                    objc_setAssociatedObject(button, &buttonActionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    defaultStackView.addArrangedSubview(button)
                    defaultActionButtons.append(button)
                case .cancel:
                    let button = cancelActionButton()
                    button.setTitle(action.title, for: .normal)
                    button.addTarget(self, action: #selector(self.didSelectAction), for: .touchUpInside)
                    objc_setAssociatedObject(button, &buttonActionKey, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                    cancelStackView.addArrangedSubview(button)
                    cancelStackView.isHidden = false
                }
            }
        }
    }
    
    private lazy var maskView: UIView = {
        let instance = UIView()
        instance.backgroundColor = .mask
        return instance
    }()
    
    private lazy var contentStackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .vertical
        instance.alignment = .fill
        instance.distribution = .fill
        return instance
    }()
    
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.backgroundColor = .white
        instance.font = .sys_16_semibold
        instance.textColor = .hex_1d1d1f
        instance.textAlignment = .center
        instance.isHidden = true
        return instance
    }()
    
    private lazy var defaultStackView: UIStackView = {
        let instance = UIStackView()
        instance.layer.cornerRadius = 8
        instance.layer.masksToBounds = true
        instance.axis = .vertical
        instance.alignment = .fill
        instance.distribution = .fill
        instance.spacing = 1 / UIScreen.main.scale
        return instance
    }()
    
    private var defaultActionButtons: [UIButton] = []
    
    private lazy var cancelStackView: UIStackView = {
        let instance = UIStackView()
        instance.layer.cornerRadius = 8
        instance.layer.masksToBounds = true
        instance.axis = .vertical
        instance.alignment = .fill
        instance.distribution = .fill
        instance.spacing = 1 / UIScreen.main.scale
        instance.isHidden = true
        return instance
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(maskView)
        maskView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([maskView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     maskView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     maskView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     maskView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 2)])
        
        view.addSubview(contentStackView)
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                                     contentStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                                     contentStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)])
        
        contentStackView.addArrangedSubview(defaultStackView)
        contentStackView.setCustomSpacing(10, after: defaultStackView)
        contentStackView.addArrangedSubview(cancelStackView)
        
        defaultStackView.insertArrangedSubview(titleLabel, at: 0)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([titleLabel.heightAnchor.constraint(equalToConstant: 44)])
    }
    
    @objc
    private func didSelectAction(_ button: UIButton) {
        dismiss(animated: true) {
            if let action = objc_getAssociatedObject(button, &buttonActionKey) as? ActionSheetAction {
                action.handler?()
            }
        }
    }
}

extension ActionSheetController {
    private func defaultActionButton() -> UIButton {
        let instance = UIButton(type: .custom)
        instance.backgroundColor = .white
        instance.setTitleColor(.hex_1d1d1f, for: .normal)
        instance.titleLabel?.font = .sys_14_semibold
        instance.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([instance.heightAnchor.constraint(equalToConstant: 44)])
        return instance
    }
    
    private func cancelActionButton() -> UIButton {
        let instance = UIButton(type: .custom)
        instance.backgroundColor = .white
        instance.setTitleColor(.hex_1d1d1f, for: .normal)
        instance.titleLabel?.font = .sys_14_semibold
        instance.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([instance.heightAnchor.constraint(equalToConstant: 44)])
        return instance
    }
}
