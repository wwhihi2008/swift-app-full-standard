//
//  FormSectionView.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/9.
//

import UIKit

@MainActor
open class FormSectionView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    open var title: String? {
        didSet {
            updateTitleLabel()
        }
    }
    
    private lazy var stackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .vertical
        instance.alignment = .fill
        instance.distribution = .equalSpacing
        instance.spacing = 8
        return instance
    }()
    
    private lazy var titleStackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .horizontal
        instance.alignment = .center
        instance.distribution = .equalSpacing
        instance.spacing = 8
        return instance
    }()
    
    private lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.numberOfLines = 0
        return instance
    }()
    
    open var titleButton: UIButton = {
        let instance = UIButton(type: .custom)
        instance.setTitleColor(.hex_1d1d1f, for: .normal)
        instance.titleLabel?.font = .sys_14
        instance.isHidden = true
        return instance
    }()
    
    open var itemViews: [UIView] = [] {
        didSet {
            oldValue.forEach { view in
                view.removeFromSuperview()
            }
            itemViews.forEach { view in
                stackView.addArrangedSubview(view)
            }
        }
    }
    
    private var isTopSection: Bool = true
    
    private func initViews() {
        directionalLayoutMargins = .zero
        insetsLayoutMarginsFromSafeArea = false
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                                     stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                                     stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)])
        
        stackView.addArrangedSubview(titleStackView)
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(titleButton)
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let superview = superview, superview is FormSectionView {
            isTopSection = false
        } else {
            isTopSection = true
        }
        updateTitleLabel()
    }
    
    private func updateTitleLabel() {
        if isTopSection {
            let attributedText = NSMutableAttributedString()
            if let image = UIImage.item_indicator {
                attributedText.append(.init(attachment: .init(image: image)))
            }
            attributedText.append(.init(string: " " + (title ?? ""), attributes: [.font: UIFont.sys_16_semibold, .foregroundColor: UIColor.hex_1d1d1f]))
            titleLabel.attributedText = attributedText
        } else {
            let attributedText = NSAttributedString(string: title ?? "", attributes: [.font: UIFont.sys_14, .foregroundColor: UIColor.hex_1d1d1f])
            titleLabel.attributedText = attributedText
        }
    }
}

extension FormSectionView {
    public var allValidatableViews: [UIView] {
        return stackView.arrangedSubviews.reduce([]) { partialResult, subview in
            if let subview = subview as? FormSectionView {
                return partialResult + subview.allValidatableViews
            } else {
                if subview is (any FormContentValidation) || subview is (any FormRequirementValidation) {
                    return partialResult + [subview]
                } else {
                    return partialResult
                }
            }
        }
    }
}
