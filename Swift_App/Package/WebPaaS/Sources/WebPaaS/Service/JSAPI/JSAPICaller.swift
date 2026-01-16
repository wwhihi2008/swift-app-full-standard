//
//  JSAPICaller.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/21.
//

import Foundation

@MainActor
open class JSAPICaller {
    public init(params: [String : Any]? = nil) {
        self.params = params
    }
    
    public private(set) var params: [String: Any]?
    
    open func call(_ apiBlock: @MainActor @escaping (_ caller: JSAPICaller) async throws -> [String: Any]?) {
        Task {
            do {
                let result = try await apiBlock(self)
                let successFunction = params?["success"] as? JSFunction
                _ = try? await successFunction?.call(param: result)
            } catch let error as JSError {
                let failFunction = params?["fail"] as? JSFunction
                _ = try? await failFunction?.call(param: error.functionParam())
            }
        }
    }
    
    open func decodeParamValue<T>(_ type: T.Type, for key: String) throws(JSError) -> T? {
        guard let value = params?[key] else {
            return nil
        }
        guard let value = value as? T else {
            throw .unexpectedServiceParamKeyValue(paramKey: key, paramValue: value)
        }
        return value
    }
}
