//
//  FormLabelCell.swift
//  UIPaaS
//
//  Created by wuwei on 2025/8/4.
//

import UIKit
import OSS

@MainActor
open class FormLabelCell: FormCell<String> {
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
            return label.text
        }
        set {
            label.text = newValue
        }
    }
    
    private lazy var label: UILabel = {
        let instance = UILabel()
        instance.font = .sys_16
        instance.textColor = .hex_1d1d1f
        return instance
    }()
        
    private func initViews() {
        fieldView.addArrangedSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([label.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)])
    }
}
