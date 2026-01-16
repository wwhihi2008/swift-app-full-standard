//
//  FormCell.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/4.
//

import UIKit

@MainActor
open class FormCell<ValueType>: UIView, FormContentValidation, FormRequirementValidation {
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
    
    open var subTitle: String? {
        didSet {
            updateTitleLabel()
        }
    }
    
    open var isRequired: Bool = false {
        didSet {
            updateTitleLabel()
        }
    }
    
    open lazy var titleLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .hex_1d1d1f
        instance.font = .sys_16
        instance.numberOfLines = 0
        return instance
    }()
    
    open lazy var fieldView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .horizontal
        instance.alignment = .center
        instance.distribution = .fill
        instance.spacing = 8
        return instance
    }()
    
    open lazy var errorLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .red
        instance.font = .sys_11
        instance.numberOfLines = 0
        return instance
    }()
    
    private func initViews() {
        directionalLayoutMargins = .zero
        insetsLayoutMarginsFromSafeArea = false
        
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([titleLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                                     titleLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                                     titleLabel.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
                                     titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)])
        
        addSubview(fieldView)
        fieldView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([fieldView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                                     fieldView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                                     fieldView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                                     fieldView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
                                     fieldView.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor, constant: -20)])
        
        addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([errorLabel.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
                                     errorLabel.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
                                     errorLabel.topAnchor.constraint(equalTo: fieldView.bottomAnchor, constant: 4),
                                     errorLabel.bottomAnchor.constraint(lessThanOrEqualTo: layoutMarginsGuide.bottomAnchor)])
    }
    
    private func updateTitleLabel() {
        let attributedText = NSMutableAttributedString()
        if isRequired {
            attributedText.append(.init(string: "* ", attributes: [.font: UIFont.sys_16, .foregroundColor: UIColor.red]))
        }
        if let title = title {
            attributedText.append(.init(string: title + "：", attributes: [.font: UIFont.sys_16, .foregroundColor: UIColor.hex_1d1d1f]))
        }
        if let subTitle = subTitle {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.paragraphSpacing = 4
            attributedText.append(.init(string: "\r\n\(subTitle)", attributes: [.font: UIFont.sys_14, .foregroundColor: UIColor.hex_999999, .paragraphStyle: paragraphStyle]))
        }
        titleLabel.attributedText = attributedText
    }
    
    open var value: ValueType?
    
    open var contentRules: [FormRule<ValueType>] = []
    
    open func validateContent() async -> Bool {
        do {
            for rule in contentRules {
                if !(try await rule.validator(value)) {
                    return false
                }
            }
            return true
        } catch {
            errorLabel.text = error.localizedDescription
            return false
        }
    }
    
    open var requirementRule: FormRule<ValueType>?
    
    open func validateRequirement() async -> Bool {
        guard isRequired, let requirementRule = requirementRule else {
            return true
        }
        
        do {
            return try await requirementRule.validator(value)
        } catch {
            errorLabel.text = error.localizedDescription
            return false
        }
    }
}
