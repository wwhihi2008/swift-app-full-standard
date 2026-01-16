//
//  DDModel.swift
//  DDApplication
//
//  Created by wuwei on 2025/6/26.
//

import Foundation

class ServiceOrderListItem: Codable {
    var id: Int?    //服务单ID
    var sysApprovalNo: String?
    var serviceOrderName: String?    //服务名称
    var pawnName: String?    //典当名称
    var inPawnAmount: Decimal?    //在当金额
    var maxCreditAmount: Decimal?    //建当金额
    var borrower: String?    //借款人
    var approvalStatus: Int?
    var approvalDetailStatus: Int?
    var serviceOrderStatus: Int?
    var submitTime: String?    //提交时间
    var checkOpinion: String?
    var borrowerType: Int?
    var warranterSignStatus: Int?
    var contractURL: String?
    var downloadUrl: String?
    var operations: [String]?
}
