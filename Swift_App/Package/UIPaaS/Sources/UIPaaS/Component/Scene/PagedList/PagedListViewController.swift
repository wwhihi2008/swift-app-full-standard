//
//  PagedListViewController.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/27.
//

import UIKit

@MainActor
open class PagedListViewController<ItemType>: DataLoadingViewController {
    open var initPage: Int = 1
    
    open private(set) var page: Int = 1
    
    open private(set) var pageLimit: Int = .max
    
    open private(set) var items: [ItemType] = [] {
        didSet {
            emptyView.isHidden = !items.isEmpty
        }
    }
    
    open var listLoader: (@MainActor (_ page: Int) async throws -> (page: Int, pageLimit: Int, items: [ItemType]))?
    
    open private(set) lazy var tableView: UITableView = {
        let instance = UITableView()
        instance.backgroundColor = .hex_f6f6f9
        instance.showsHorizontalScrollIndicator = false
        instance.showsVerticalScrollIndicator = false
        instance.headerRefreshControl = headerControl
        instance.footerRefreshControl = footerControl
        instance.backgroundView = emptyView
        instance.keyboardDismissMode = .onDrag
        return instance
    }()
    
    open private(set) lazy var headerControl: HeaderRefreshControl = {
        let instance = HeaderRefreshControl()
        instance.didBeginRefreshingHandler = { [weak self] in
            self?.headerControlDidBeginRefreshing()
        }
        return instance
    }()
    
    open private(set) lazy var footerControl: FooterRefreshControl = {
        let instance = FooterRefreshControl()
        instance.didBeginRefreshingHandler = { [weak self] in
            self?.footerControlDidBeginRefreshing()
        }
        return instance
    }()
    
    open private(set) lazy var emptyView: ErrorView = {
        let instance = ErrorView.empty()
        instance.isHidden = true
        return instance
    }()
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        dataView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([tableView.leadingAnchor.constraint(equalTo: dataView.safeAreaLayoutGuide.leadingAnchor),
                                     tableView.trailingAnchor.constraint(equalTo: dataView.safeAreaLayoutGuide.trailingAnchor),
                                     tableView.topAnchor.constraint(equalTo: dataView.safeAreaLayoutGuide.topAnchor),
                                     tableView.bottomAnchor.constraint(equalTo: dataView.bottomAnchor)])
        
        dataLoader = { [weak self] in
            guard let self = self, let listLoader = self.listLoader else {
                return
            }
            let result = try await listLoader(self.initPage)
            self.page = result.page
            self.pageLimit = result.pageLimit
            self.items = result.items
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
    open func simulateRefreshing() {
        guard !tableView.isHidden, !headerControl.isRefreshing else {
            return
        }
        headerControl.simulateRefreshing()
    }
    
    private func headerControlDidBeginRefreshing() {
        footerControl.isHidden = true
        footerTask?.cancel()
        
        Task {
            do {
                guard let listLoader = listLoader else {
                    return
                }
                let result = try await listLoader(initPage)
                page = result.page
                pageLimit = result.pageLimit
                items = result.items
                tableView.reloadData()
            } catch {
                guard !(error is NopError) else {
                    return
                }
                view.window?.toast(error.localizedDescription)
            }
            headerControl.endRefreshing()
            if (page < pageLimit) {
                footerControl.reset()
            } else {
                footerControl.complete()
            }
        }
    }
    
    private var footerTask: Task<(), Never>?
    
    private func footerControlDidBeginRefreshing() {
        footerTask?.cancel()
        
        footerTask = Task {
            do {
                guard let listLoader = listLoader else {
                    return
                }
                let result = try await listLoader(page + 1)
                if Task.isCancelled {
                    return
                }
                page = result.page
                pageLimit = result.pageLimit
                let originalCount = items.count
                items.append(contentsOf: result.items)
                tableView.insertRows(at: (originalCount ..< originalCount + result.items.count).map({ index in
                    return .init(row: index, section: 0)
                }), with: .fade)
            } catch {
                if Task.isCancelled {
                    return
                }
                guard !(error is NopError) else {
                    return
                }
                view.window?.toast(error.localizedDescription)
            }
            if (page < pageLimit) {
                footerControl.endRefreshing()
            } else {
                footerControl.complete()
            }
        }
    }
    
    open func removeItem(at index: Int) {
        items.remove(at: index)
        tableView.deleteRows(at: [.init(row: index, section: 0)], with: .fade)
    }
}
