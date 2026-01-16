//
//  UITextField+Toolbar.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/29.
//

import UIKit

extension UITextField {
    public func setInputToolbar() {
        let toolbar = UIToolbar(frame: .init(x: 0, y: 0, width: 0, height: 44))
        let doneItem = UIBarButtonItem(title: "完成", style: .plain, target: self, action: #selector(self.toolbarDidClickCompletion))
        doneItem.tintColor = .hex_1d1d1f
        toolbar.items = [.flexibleSpace(), doneItem]
        inputAccessoryView = toolbar
    }
    
    @objc
    private func toolbarDidClickCompletion() {
        endEditing(true)
    }
}
