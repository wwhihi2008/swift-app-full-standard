//
//  JSFunction.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/6.
//

import Foundation
import WebKit

@MainActor
open class JSFunction {
    deinit {
        let content_temp = context
        let functionID_temp = functionID
        Task { @MainActor in
            let js = content_temp.functionRemoveScript(functionID_temp)
            _ = try? await content_temp.webView?.evaluateJavaScript(js)
        }
    }
    
    public init(context: JSContext, functionID: String) {
        self.context = context
        self.functionID = functionID
    }
    
    open var context: JSContext
    
    open var functionID: String
    
    open func call(param: [String: Any]?) async throws -> Any? {
        let js = context.functionCallScript(functionID, try param.flatMap({ value in
            return String(data: try JSONSerialization.data(withJSONObject: value), encoding: .utf8)
        }))
        guard let webView = context.webView else {
            throw JSError.webviewNotFound
        }
        return try await webView.evaluateJavaScript(js)
    }
}

extension JSError {
    func functionParam() -> [String: Any] {
        return ["code": code,
                "message": message]
    }
}
