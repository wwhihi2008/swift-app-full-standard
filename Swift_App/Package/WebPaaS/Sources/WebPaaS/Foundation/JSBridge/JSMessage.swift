//
//  JSMessage.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/7.
//

import Foundation
import WebKit

open class JSAPICallMessage: @unchecked Sendable {
    open var bridge: String?
    open var apiName: String?
    open var param: [String: Any] = [:]
    open var callback: JSFunction?
}

extension WKScriptMessage {
    public var jsApiCallMessage: JSAPICallMessage {
        let call = JSAPICallMessage()
        
        guard let body = body as? [String: Any] else {
            return call
        }
        
        call.bridge = body["bridge"] as? String
        call.apiName = body["apiName"] as? String
        call.param = (body["param"] as? [String: Any]).flatMap({ value in
            return parseBridgeObject(object: value) as? [String: Any]
        }) ?? [:]
        call.callback = (body["callback"] as? String).flatMap({ value in
            return parseBridgeObject(object: value) as? JSFunction
        })
        return call
    }
    
    private func parseBridgeObject(object: Any) -> Any? {
        if object is NSNull {
            return nil
        }
        
        guard let context = webView?.jsContext else {
            return nil
        }

        if let message = object as? String {
            if message.hasPrefix(context.functionIdentifier), let functionID = URLComponents(string: message)?.queryItems?.first(where: { element in
                return element.name == "functionID"
            })?.value {
                return JSFunction(context: context, functionID: functionID)
            } else {
                return message
            }
        } else if let message = object as? NSArray {
            return message.compactMap { item in
                return parseBridgeObject(object: item)
            }
        } else if let message = object as? NSDictionary {
            guard let dicMessage = message as? [String: Any] else {
                return nil
            }
            return dicMessage.compactMapValues { value in
                return parseBridgeObject(object: value)
            }
        } else {
            return object
        }
    }
}
