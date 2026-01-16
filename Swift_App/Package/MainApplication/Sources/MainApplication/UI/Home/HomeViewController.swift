//
//  HomeViewController.swift
//  MainApplication
//
//  Created by wuwei on 2025/6/26.
//

import UIKit
import UIPaaS

class HomeViewController: DataRefreshingViewController {
    private lazy var contentLabel: UILabel = {
        let instance = UILabel()
        return instance
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "首页"
        
        contentView.addSubview(contentLabel)
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentLabel.leadingAnchor.constraint(equalTo: contentView.contentLayoutGuide.leadingAnchor),
                                     contentLabel.trailingAnchor.constraint(equalTo: contentView.contentLayoutGuide.trailingAnchor),
                                     contentLabel.topAnchor.constraint(equalTo: contentView.contentLayoutGuide.topAnchor),
                                     contentLabel.heightAnchor.constraint(equalToConstant: 400)])
        
        dataRefresher = { [weak self] in
            try await self?.fetchData()
        }
        
//        let form = FormPickerFieldCell<Date>()
//        form.title = "项目1"
//        form.placeholder = "请选择"
//        form.isRequired = true
//        form.didEndFormEditingHandler = { [weak self] value in
//            Task {
//                await form.validateRequirement()
//            }
//        }
//        form.contentRules = [.init(validator: { date in
//            if let date = date, date > .now {
//                throw FormRuleError(message: "大大大大大了大大大大大了大大大大大了大大大大大了大大大大大了大大大大大了大大大大大了大大大大大了大大大大大了大大大大大了大大大大大了")
//            }
//            return true
//        })]
//        let datePicker = DatePickerViewController()
//        form.setDatePicker(datePicker)
        
        
        
    }
    
    private func fetchData() async throws {
        let data = try await DDService.shared.getCarApprovalOrderStatisticalMyData(dimension: 1)
        contentLabel.text = data?.dropdownDTOS?.compactMap({ value in
            return value.label
        }).joined(separator: "-")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        return
        
//        let preview = ImagePreviewKitViewController()
//        preview.urls = [.init(string: "https://static.xiaofengwang.com/test/img/bd3407cb0b2c4183bcc2339d63f393d4.jpeg")!, .init(string: "https://static.xiaofengwang.com/test/img/7a9096675eb84a888d85730b1a51febe.jpg")!]
//        preview.modalPresentationStyle = .overFullScreen
//        present(preview, animated: true)
        
        let formCell = FormFileUploaderCell()
        formCell.title = "项目1"
        formCell.isRequired = true
        formCell.pickers = [FileUploadCameraPicker(fileType: .photo, sizeLimit: 0),
                                             FileUploadPhotosPicker(filter: .images, selectionLimit: 3, sizeLimits: [.image: 1 * 1000 * 1000]),
                                             FileUploadDocumentPicker(utis: [.item], sizeLimit: 10 * 1024 * 1024)]
        formCell.fixedFiles = [.init(fileKey: "dev/1CED945F-33D9-4D97-8FBD-9D742AD7630D", fileName: "D2DA7887-AB8F-4385-9192-BB60C51519BC.jpeg", fileSize: 964308, fileType: "image/jpeg", fileUrl: .init(string: "https://static.xiaofengwang.com/dev/1CED945F-33D9-4D97-8FBD-9D742AD7630D")),
                                                .init(fileKey: "dev/68D7B498-4CC2-49BC-92CD-40B2ABA116E8", fileName: "F90979B1-18DD-472B-957E-C7E84EAF3BA4.jpeg", fileSize: 157407, fileType: "image/jpeg", fileUrl: .init(string: "https://static.xiaofengwang.com/dev/68D7B498-4CC2-49BC-92CD-40B2ABA116E8"))]
        formCell.value = [.init(fileKey: "dev/1CED945F-33D9-4D97-8FBD-9D742AD7630D", fileName: "D2DA7887-AB8F-4385-9192-BB60C51519BC.jpeg", fileSize: 964308, fileType: "image/jpeg", fileUrl: .init(string: "https://static.xiaofengwang.com/dev/1CED945F-33D9-4D97-8FBD-9D742AD7630D")),
                          .init(fileKey: "dev/68D7B498-4CC2-49BC-92CD-40B2ABA116E8", fileName: "F90979B1-18DD-472B-957E-C7E84EAF3BA4.jpeg", fileSize: 157407, fileType: "image/jpeg", fileUrl: .init(string: "https://static.xiaofengwang.com/dev/68D7B498-4CC2-49BC-92CD-40B2ABA116E8"))]
        
        let formCell2 = FormTextFieldCell()
        formCell2.title = "项目2"
        formCell2.placeholder = "请选择"
        formCell2.accessoryText = "55544"
        formCell2.isRequired = true

        formCell2.contentRules = [.maxWords(limit: 10)]
        
        let formCell3 = FormLabelCell()
        formCell3.title = "项目3"
        formCell3.value = "111"
        
        let formSection = FormSectionView()
        formSection.title = "xiangmu"
        formSection.titleButton.setTitle("66", for: .normal)
        formSection.titleButton.isHidden = false
        formSection.itemViews = [formCell, formCell2, formCell3]
        
        let formController = FormViewController()
        formController.formView.sectionViews = [formSection]
        formController.dataLoader = {
            return
        }
        formController.actionBar.actions = [.init(title: "ok", style: .primary, handler: {
            formController.submit()
        })]
        
        present(formController, animated: true)
    }
}
