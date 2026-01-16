//
//  DatePickerViewController.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/28.
//

import UIKit

@MainActor
open class DatePickerViewController: ActionedPickerViewController {
    open var date: Date? {
        get {
            return datePicker.date
        }
        set {
            datePicker.date = newValue ?? .now
        }
    }
    
    open var minimumDate: Date? {
        get {
            return datePicker.minimumDate
        }
        set {
            datePicker.minimumDate = newValue
        }
    }
    
    open var maximumDate: Date? {
        get {
            return datePicker.maximumDate
        }
        set {
            datePicker.maximumDate = newValue
        }
    }
    
    open var didPickDateHandler: ((_ date: Date?) -> Void)?
    
    private lazy var datePicker: UIDatePicker = {
        let instance = UIDatePicker()
        instance.locale = .init(identifier: "zh_CN")
        instance.datePickerMode = .date
        instance.preferredDatePickerStyle = .wheels
        return instance
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "日期选择"
        
        view.addSubview(datePicker)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([datePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                                     datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                                     datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     datePicker.bottomAnchor.constraint(equalTo: actionBar.topAnchor)])
        
        actionBar.actions = [.init(title: "清空", style: .secondary, handler: { [weak self] in
            guard let self = self else {
                return
            }
            self.date = nil
            self.done()
        }), .init(title: "确定", style: .primary, handler: { [weak self] in
            guard let self = self else {
                return
            }
            self.date = self.datePicker.date
            self.done()
        })]
    }
    
    private func done() {
        dismiss(animated: true) {
            self.didPickDateHandler?(self.date)
        }
    }
}
