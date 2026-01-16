//
//  FormTextFieldCell.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/7.
//

import UIKit

@MainActor
open class FormTextFieldCell: FormEditableFieldCell<String>, UITextFieldDelegate {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    open override var value: String? {
        get {
            return textFiled.text
        }
        set {
            textFiled.text = newValue
        }
    }
    
    open var placeholder: String? {
        get {
            return textFiled.placeholder
        }
        set {
            textFiled.placeholder = newValue
        }
    }
    
    open var accessoryText: String? {
        didSet {
            accessoryLabel.text = accessoryText
            accessoryLabel.isHidden = !(accessoryText?.isEmpty == false)
        }
    }
    
    open var maxCount: Int = -1
    
    private lazy var textFiled: UITextField = {
        let instance = UITextField()
        instance.textColor = .hex_1d1d1f
        instance.font = .sys_16
        instance.clearButtonMode = .whileEditing
        instance.delegate = self
        instance.setInputToolbar()
        return instance
    }()
    
    private lazy var accessoryLabel: UILabel = {
        let instance = UILabel()
        instance.textColor = .hex_1d1d1f
        instance.font = .sys_16
        instance.textAlignment = .right
        instance.isHidden = true
        return instance
    }()
        
    private func initViews() {
        fieldView.addBorders([.init(position: .bottom, width: 1, color: .hex_cccccc)])
        
        fieldView.addArrangedSubview(textFiled)
        textFiled.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([textFiled.heightAnchor.constraint(equalToConstant: 24)])
        textFiled.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textFiled.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        fieldView.addArrangedSubview(accessoryLabel)
        accessoryLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        accessoryLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        requirementRule = .requirement()
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        beginFormEditing()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        endFormEditing()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if maxCount > 0, let count = (textFiled.text as? NSString)?.replacingCharacters(in: range, with: string).count, count > maxCount {
            return false
        }
        return true
    }
}
