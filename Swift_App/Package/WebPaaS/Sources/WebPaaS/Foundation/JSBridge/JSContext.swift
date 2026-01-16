//
//  JSContext.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/6.
//

import Foundation
import WebKit

nonisolated(unsafe)
private var jsContextKey: Void?

extension WKWebView {
    public var jsContext: JSContext {
        if let value = objc_getAssociatedObject(self, &jsContextKey) as? JSContext {
            return value
        } else {
            let value = JSContext(webView: self)
            objc_setAssociatedObject(self, &jsContextKey, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return value
        }
    }
}

@MainActor
open class JSContext {
    public init(webView: WKWebView) {
        self.webView = webView
    }
    
    public private(set) weak var webView: WKWebView?
    
    public let bridge: String = "bbBridge"
    
    /// 遵循js命名规范，需要去掉各类特殊字符
    lazy var messageHandler: String = "m" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
    /// 遵循js命名规范，需要去掉各类特殊字符
    lazy var functionIdentifier: String = "f" + UUID().uuidString.replacingOccurrences(of: "-", with: "")
}

// MARK: - JSScript

extension JSContext {
    private static let initScriptTemplate = """
        var $bridge = new Object()
        $bridge.functionPool = (function () {
            var functionPool = new Object()
            functionPool.functions = {}
            functionPool.functionFlag = 1
            functionPool.addFunction = function (func) {
                var functionID = this.functionFlag.toString()
                this.functions[functionID] = func
                this.functionFlag ++
                return functionID
            }
            functionPool.removeFunction = function (functionID) {
                delete this.functions[functionID]
            }
            functionPool.removeAllFunctions = function () {
                this.functions = {}
            }
            functionPool.getFunction = function (functionID) {
                return this.functions[functionID]
            }
            return functionPool
        })();
        
        $bridge.call = function(apiName, param=null) {
            return new Promise(function (resolve, reject) {
                var message = new Object()
                message.bridge = "$bridge"
                message.apiName = apiName + ":"
                message.param = param
                message.callback = function (error) {
                    if (error) {
                        reject(error)
                    }
                    else {
                        resolve()
                    }
                }
        
                function serialize(obj) {
                    var type = Object.prototype.toString.call(obj)
                    if (type == "[object Function]") {
                        var functionID = $bridge.functionPool.addFunction(obj)
                        return "$functionIdentifier?functionID=" + functionID
                    }
                    else if (type == "[object Object]") {
                        Object.keys(obj).map(item => obj[item] = serialize(obj[item]))
                        return obj
                    }
                    else if (type == "[object Array]") {
                        return obj.map(function (item) {
                            return serialize(item)
                        })
                    }
                    else {
                        return obj
                    }
                }

                var serializedMessage = serialize(message)
        
                window.webkit.messageHandlers.$messageHandler.postMessage(serializedMessage)
            })
        }
"""
    
    public func initScript() -> String {
        return Self.initScriptTemplate
            .replacingOccurrences(of: "$bridge", with: bridge)
            .replacingOccurrences(of: "$messageHandler", with: messageHandler)
            .replacingOccurrences(of: "$functionIdentifier", with: functionIdentifier)
    }
    
    private static let functionCallScriptTemplate = """
        var func = $bridge.functionPool.getFunction(&functionID)
        func(&param)
"""
    
    public func functionCallScript(_ functionID: String, _ param: String?) -> String {
        return Self.functionCallScriptTemplate
            .replacingOccurrences(of: "$bridge", with: bridge)
            .replacingOccurrences(of: "&functionID", with: "\"\(functionID)\"")
            .replacingOccurrences(of: "&param", with: param ?? "null")
    }
    
    private static let functionRemoveScriptTemplate = """
        var func = $bridge.functionPool.removeFunction(&functionID)
"""
    
    public func functionRemoveScript(_ functionID: String) -> String {
        return Self.functionRemoveScriptTemplate
            .replacingOccurrences(of: "$bridge", with: bridge)
            .replacingOccurrences(of: "&functionID", with: "\"\(functionID)\"")
    }
}

