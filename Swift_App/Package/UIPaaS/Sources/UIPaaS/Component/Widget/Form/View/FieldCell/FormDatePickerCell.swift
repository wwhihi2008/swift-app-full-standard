//
//  FormDatePickerCell.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/28.
//

import UIKit

@MainActor
open class FormDatePickerCell: FormPickerCell<Date> {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    open var minimumDate: Date?
    open var maximumDate: Date?
    
    private func initViews() {
        formatter = { date in
            return date.formatted_date()
        }
        
        requirementRule = .requirement()
        
        didBeginFormEditingHandler = { [weak self] in
            guard let self = self else {
                return
            }
            let host = PresentHostingViewController()
            host.firstContentViewController = self.createDatePicker()
            host.closeHandler = { [weak self] in
                guard let self = self else {
                    return
                }
                self.endFormEditing()
            }
            responderController?.present(host, animated: true)
        }
    }
    
    private func createDatePicker() -> DatePickerViewController {
        let picker = DatePickerViewController()
        picker.date = value
        picker.minimumDate = minimumDate
        picker.maximumDate = maximumDate
        picker.didPickDateHandler = { [weak self] date in
            guard let self = self else {
                return
            }
            self.value = date
            self.endFormEditing()
        }
        return picker
    }
}
