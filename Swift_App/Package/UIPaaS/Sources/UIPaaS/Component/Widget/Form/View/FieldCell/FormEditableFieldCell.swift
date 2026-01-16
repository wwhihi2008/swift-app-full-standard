//
//  FormEditableFieldCell.swift
//  UIPaaS
//
//  Created by wuwei on 2025/11/27.
//

import UIKit

@MainActor
open class FormEditableFieldCell<ValueType>: FormCell<ValueType> {
    open private(set) var valueChanged: Bool = false
    
    open var didBeginFormEditingHandler: (@MainActor () -> Void)?
    open var didEndFormEditingHandler: (@MainActor (ValueType?) -> Void)?
    
    open func beginFormEditing() {
        errorLabel.text = nil
        didBeginFormEditingHandler?()
    }
    
    open func endFormEditing() {
        valueChanged = true
        Task {
            _ = await validateRequirement()
            _ = await validateContent()
            didEndFormEditingHandler?(value)
        }
    }
}
