//
//  JSError+Service.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/18.
//

import Foundation

extension JSError {
    public static let serviceNotFound: Self = .init(code: 10101, message: "服务不存在")
    
    public static func unexpectedServiceParamKeyValue(paramKey: String, paramValue: Any?) -> Self {
        return .init(code: 10102, message: "params error：\(paramKey) - \(paramValue == nil ? "null" : String(describing: paramValue))")
    }
    
    public static func unexpectedServiceParam(paramKey: String) -> Self {
        return .init(code: 10102, message: "params error：unexpected \(paramKey)")
    }
}

extension JSError {
    public static let imageSaveError: Self = .init(code: 20001, message: "图片保存失败")
}
