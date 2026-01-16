//
//  FormPickerCell.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/28.
//

import UIKit

@MainActor
open class FormPickerCell<ValueType>: FormEditableFieldCell<ValueType> {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    open override var value: ValueType? {
        didSet {
            updatePickerLabel()
        }
    }
        
    open var formatter: ((ValueType) -> String?)?
    
    open var placeholder: String? {
        didSet {
            updatePickerLabel()
        }
    }
    
    open lazy var pickerField: UIControl = {
        let instance = UIControl()
        instance.addTarget(self, action: #selector(self.pickerFieldDidClick), for: .touchUpInside)
        return instance
    }()
    
    @objc
    private func pickerFieldDidClick() {
        beginFormEditing()
    }
    
    private lazy var pickerLabel: UILabel = {
        let instance = UILabel()
        return instance
    }()
    
    private lazy var indicatorView: UIView = {
        let instance = UIImageView()
        instance.image = .icon(named: IconName.icon_right.rawValue, fontSize: 14, color: .hex_cccccc)
        return instance
    }()
    
    private func initViews() {
        fieldView.addBorders([.init(position: .bottom, width: 1, color: .hex_cccccc)])
        
        fieldView.addArrangedSubview(pickerField)
        pickerField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([pickerField.heightAnchor.constraint(equalToConstant: 24)])
        
        pickerField.addSubview(pickerLabel)
        pickerLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([pickerLabel.leadingAnchor.constraint(equalTo: pickerField.leadingAnchor),
                                     pickerLabel.trailingAnchor.constraint(equalTo: pickerField.trailingAnchor),
                                     pickerLabel.topAnchor.constraint(equalTo: pickerField.topAnchor),
                                     pickerLabel.bottomAnchor.constraint(equalTo: pickerField.bottomAnchor)])
        
        fieldView.addArrangedSubview(indicatorView)
    }
    
    private func updatePickerLabel() {
        if let value = value, let formatter = formatter, let text = formatter(value), !text.isEmpty {
            pickerLabel.attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.sys_16, .foregroundColor: UIColor.hex_1d1d1f])
        } else {
            pickerLabel.attributedText = NSAttributedString(string: placeholder ?? "", attributes: [.font: UIFont.sys_16, .foregroundColor: UIColor.placeholderText])
        }
    }
}
