//
//  DataRefreshingViewController.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/24.
//

import UIKit

@MainActor
open class DataRefreshingViewController: DataLoadingViewController {
    open var dataRefresher: (@MainActor () async throws -> Void)?
    
    open private(set) lazy var contentView: UIScrollView = {
        let instance = UIScrollView()
        instance.showsHorizontalScrollIndicator = false
        instance.showsVerticalScrollIndicator = false
        instance.alwaysBounceVertical = true
        instance.headerRefreshControl = headerControl
        return instance
    }()
    
    open private(set) lazy var headerControl: HeaderRefreshControl = {
        let instance = HeaderRefreshControl()
        instance.didBeginRefreshingHandler = { [weak self] in
            self?.didBeginRefreshing()
        }
        return instance
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        dataView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentView.leadingAnchor.constraint(equalTo: dataView.safeAreaLayoutGuide.leadingAnchor),
                                     contentView.trailingAnchor.constraint(equalTo: dataView.safeAreaLayoutGuide.trailingAnchor),
                                     contentView.topAnchor.constraint(equalTo: dataView.safeAreaLayoutGuide.topAnchor),
                                     contentView.bottomAnchor.constraint(equalTo: dataView.bottomAnchor),
                                     contentView.contentLayoutGuide.widthAnchor.constraint(equalTo: contentView.frameLayoutGuide.widthAnchor)])
        
        dataLoader = { [weak self] in
            guard let self = self else {
                return
            }
            try await self.dataRefresher?()
        }
    }
    
    private func didBeginRefreshing() {
        Task {
            do {
                guard let loadDataHandler = dataRefresher else {
                    return
                }
                try await loadDataHandler()
            } catch {
                guard !(error is NopError) else {
                    return
                }
                view.window?.toast(error.localizedDescription)
            }
            headerControl.endRefreshing()
        }
    }
}
