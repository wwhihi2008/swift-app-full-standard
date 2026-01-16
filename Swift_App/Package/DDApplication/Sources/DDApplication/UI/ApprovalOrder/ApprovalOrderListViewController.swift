//
//  ApprovalOrderListViewController.swift
//  MainApplication
//
//  Created by wuwei on 2025/6/26.
//

import UIKit
import UIPaaS

class ApprovalOrderListViewController: PagedListViewController<ServiceOrderListItem>, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "列表"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        listLoader = { [weak self] page in
            return try await self?.fetchData(page: page) ?? (page, .max, [])
        }
    }
    
    private func fetchData(page: Int) async throws -> (page: Int, pageLimit: Int, items: [ServiceOrderListItem]) {
        let data = try await DDService.shared.getServiceOrderList(query: .init(page: page, limit: 10, order: nil, sort: nil), dimension: 1)
        return (data?.page ?? page, data?.pages ?? .max, data?.list ?? [])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = item.borrower
        return cell
    }
}
