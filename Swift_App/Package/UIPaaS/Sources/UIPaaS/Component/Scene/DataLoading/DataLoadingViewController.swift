//
//  DataLoadingViewController.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/24.
//

import UIKit

@MainActor
open class DataLoadingViewController: UIViewController {
    open var dataLoader: (@MainActor () async throws -> Void)?
    
    open lazy var dataView: UIView = {
        let instance = UIView()
        instance.isHidden = true
        return instance
    }()
    
    open lazy var errorView: ErrorView = {
        let instance = ErrorView.dataError { [weak self] in
            self?.beginLoadingData()
        }
        instance.isHidden = true
        return instance
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(dataView)
        dataView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([dataView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     dataView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     dataView.topAnchor.constraint(equalTo: view.topAnchor),
                                     dataView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        view.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     errorView.topAnchor.constraint(equalTo: view.topAnchor),
                                     errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        _ = dataLoadOnce
    }
    
    private lazy var dataLoadOnce: Void = {
        beginLoadingData()
    }()
    
    private var dataLoading: Bool = false
    
    private func beginLoadingData() {
        guard !dataLoading, let loadDataHandler = dataLoader else {
            return
        }
        Task {
            dataLoading = true
            view.beginLoading()
            do {
                try await loadDataHandler()
                dataView.isHidden = false
                errorView.isHidden = true
            } catch {
                guard !(error is NopError) else {
                    return
                }
                dataView.isHidden = true
                errorView.isHidden = false
                errorView.message = error.localizedDescription
            }
            view.endLoading()
            dataLoading = false
        }
    }
}
