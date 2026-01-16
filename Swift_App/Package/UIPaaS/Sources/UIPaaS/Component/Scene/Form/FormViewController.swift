//
//  FormViewController.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/10.
//

import UIKit

@MainActor
open class FormViewController: DataLoadingViewController {
    open lazy var contentView: UIScrollView = {
        let instance = UIScrollView()
        instance.backgroundColor = .hex_f6f6f9
        instance.showsHorizontalScrollIndicator = false
        instance.showsVerticalScrollIndicator = false
        instance.bounces = false
        return instance
    }()
    
    open lazy var formView: FormView = {
        let instance = FormView()
        instance.directionalLayoutMargins = .init(top: 20, leading: 16, bottom: 10, trailing: 16)
        return instance
    }()
    
    open lazy var actionBar: ActionBar = {
        let instance = ActionBar()
        return instance
    }()
    
    private lazy var keyboardAdapter: ScrollViewKeyboardAdapter = .init(responderView: contentView, offsetY: 10)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        dataView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentView.leadingAnchor.constraint(equalTo: dataView.safeAreaLayoutGuide.leadingAnchor),
                                     contentView.trailingAnchor.constraint(equalTo: dataView.safeAreaLayoutGuide.trailingAnchor),
                                     contentView.topAnchor.constraint(equalTo: dataView.safeAreaLayoutGuide.topAnchor),
                                     contentView.contentLayoutGuide.widthAnchor.constraint(equalTo: contentView.frameLayoutGuide.widthAnchor)])
        
        contentView.addSubview(formView)
        formView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([formView.leadingAnchor.constraint(equalTo: contentView.contentLayoutGuide.leadingAnchor),
                                     formView.trailingAnchor.constraint(equalTo: contentView.contentLayoutGuide.trailingAnchor),
                                     formView.topAnchor.constraint(equalTo: contentView.contentLayoutGuide.topAnchor),
                                     formView.bottomAnchor.constraint(equalTo: contentView.contentLayoutGuide.bottomAnchor)])
        
        view.addSubview(actionBar)
        actionBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([actionBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                     actionBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                                     actionBar.topAnchor.constraint(equalTo: contentView.bottomAnchor),
                                     actionBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        keyboardAdapter.start()
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardAdapter.stop()
    }
    
    open func validateForm(_ includingRequirement: Bool = true) async -> Bool {
        await withTaskGroup { group in
            for cell in formView.sectionViews.reduce([], { partialResult, section in
                return partialResult + section.allValidatableViews
            }) {
                group.addTask {
                    if includingRequirement, let cell = cell as? (any FormRequirementValidation), !(await cell.validateRequirement()) {
                        return false
                    }
                    if let cell = cell as? (any FormContentValidation), !(await cell.validateContent()) {
                        return false
                    }
                    return true
                }
            }
            
            var result = true
            for await taskResult in group {
                result = taskResult && result
            }
            return result
        }
    }
    
    open var dataSubmitter: (@MainActor () async throws -> Void)?
    
    open func submit(_ includingRequirement: Bool = true) {
        Task {
            do {
                guard await validateForm(includingRequirement) else {
                    return
                }
                try await dataSubmitter?()
            } catch {
                guard !(error is NopError) else {
                    return
                }
                view.window?.toast(error.localizedDescription)
            }
        }
    }
}
