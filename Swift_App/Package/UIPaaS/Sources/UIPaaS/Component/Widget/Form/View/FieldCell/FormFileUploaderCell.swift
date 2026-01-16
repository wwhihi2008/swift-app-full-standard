//
//  FormFileUploaderCell.swift
//  UIPaaS
//
//  Created by wuwei on 2025/8/4.
//

import UIKit
import OSS

@MainActor
open class FormFileUploaderCell: FormEditableFieldCell<[OSSFile]> {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initViews()
    }
    
    open override var value: [OSSFile]? {
        get {
            return fileUploaderView.files
        }
        set {
            fileUploaderView.files = newValue ?? []
        }
    }
    
    open var fixedFiles: [OSSFile]? {
        get {
            return fileUploaderView.fixedFiles
        }
        set {
            fileUploaderView.fixedFiles = newValue ?? []
        }
    }
    
    open var pickers: [FileUploadPicker] {
        get {
            return fileUploaderView.pickers
        }
        set {
            fileUploaderView.pickers = newValue
        }
    }
    
    open var filesLimit: Int {
        get {
            return fileUploaderView.filesLimit
        }
        set {
            fileUploaderView.filesLimit = newValue
        }
    }
    
    open var isUploading: Bool {
        return fileUploaderView.isUploading
    }
    
    private lazy var fileUploaderView: FileUploaderView = {
        let instance = FileUploaderView()
        instance.filesDidChangeHandler = { [weak self] _ in
            guard let self = self else {
                return
            }
            self.filesDidChange()
        }
        return instance
    }()
        
    private func initViews() {
        fieldView.addArrangedSubview(fileUploaderView)
        fileUploaderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([fileUploaderView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)])
                
        requirementRule = .requirement()
    }
    
    private func filesDidChange() {
        errorLabel.text = nil
        endFormEditing()
    }
}
