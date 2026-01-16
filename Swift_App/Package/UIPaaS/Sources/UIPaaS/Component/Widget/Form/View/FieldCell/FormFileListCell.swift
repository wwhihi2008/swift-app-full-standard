//
//  FormFileListCell.swift
//  UIPaaS
//
//  Created by wuwei on 2025/8/4.
//

import UIKit
import OSS

@MainActor
open class FormFileListCell: FormCell<[OSSFile]> {
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
            return fileListView.files
        }
        set {
            fileListView.files = newValue ?? []
        }
    }
    
    private lazy var fileListView: FileListView = {
        let instance = FileListView()
        return instance
    }()
        
    private func initViews() {
        fieldView.addArrangedSubview(fileListView)
        fileListView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([fileListView.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)])
    }
}
