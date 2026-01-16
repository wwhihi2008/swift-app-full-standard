//
//  JSController.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/7.
//

import Foundation
import WebKit

nonisolated(unsafe)
private var jsControllerKey: Void?

extension WKWebView {
    public var jsController: JSController? {
        get {
            return objc_getAssociatedObject(self, &jsControllerKey) as? JSController
        }
        set {
            objc_setAssociatedObject(self, &jsControllerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            configuration.userContentController.removeScriptMessageHandler(forName: jsContext.messageHandler)
            if let newValue = newValue {
                configuration.userContentController.addUserScript(.init(source: jsContext.initScript(), injectionTime: .atDocumentStart, forMainFrameOnly: false))
                configuration.userContentController.add(newValue, name: jsContext.messageHandler)
            }
        }
    }
}

@MainActor
open class JSController: NSObject, WKScriptMessageHandler {
    open var apiSet: JSAPISet?
    
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let jsContext = message.webView?.jsContext, jsContext.messageHandler == message.name else {
            return
        }
        
        let apiCallMessage = message.jsApiCallMessage
        
        Task { @MainActor in
            do {
                guard apiCallMessage.bridge == jsContext.bridge else {
                    throw JSError.nativeBridgeNotFound
                }
                guard let apiSet = apiSet, let apiName = apiCallMessage.apiName else {
                    throw JSError.nativeAPINotFound
                }
                let selector = Selector(apiName)
                guard apiSet.responds(to: selector) else {
                    throw JSError.nativeAPINotFound
                }
                apiSet.perform(selector, with: apiCallMessage.param)
                _ = try? await apiCallMessage.callback?.call(param: nil)
            } catch let error as JSError {
                _ = try await apiCallMessage.callback?.call(param: error.functionParam())
            }
        }
    }
}
