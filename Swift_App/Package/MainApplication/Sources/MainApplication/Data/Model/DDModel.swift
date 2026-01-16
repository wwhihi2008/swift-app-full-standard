//
//  DDModel.swift
//  MainApplication
//
//  Created by wuwei on 2025/6/26.
//

import Foundation

class HomeServiceOrderDropdownResult: Codable {
    var dimension: Int?
    var dropdownDTOS: [HomeServiceOrderDropdownDTO]?
}

class HomeServiceOrderDropdownDTO: Codable {
    var approvalStatus: Int?
    var approvalDetailStatus: Int?
    var serviceOrderStatus: Int?
    var label: String?
    var num: String?
    var dimension: Int?
}
