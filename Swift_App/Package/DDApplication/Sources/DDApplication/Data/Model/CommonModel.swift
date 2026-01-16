//
//  Common.swift
//  DDApplication
//
//  Created by wuwei on 2025/7/2.
//

import Foundation

open class PageQuery: Codable, @unchecked Sendable {
    open var page: Int?
    open var limit: Int?
    open var order: String?
    open var sort: String?
    
    public init(page: Int? = nil, limit: Int? = nil, order: String? = nil, sort: String? = nil) {
        self.page = page
        self.limit = limit
        self.order = order
        self.sort = sort
    }
}

open class PageResult<ItemType>: Codable, @unchecked Sendable where ItemType: Codable {
    open var limit: Int?
    open var page: Int?
    open var pages: Int?
    open var total: Int?
    open var list: [ItemType]?
    
    public init(limit: Int? = nil, page: Int? = nil, pages: Int? = nil, total: Int? = nil, list: [ItemType]? = nil) {
        self.limit = limit
        self.page = page
        self.pages = pages
        self.total = total
        self.list = list
    }
}
