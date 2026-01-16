//
//  JSAPI+Event.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/11.
//

import Foundation

nonisolated(unsafe)
private var eventBusKey: Void?

@MainActor
extension JSAPIBus {
    var eventBus: WebEventBus? {
        get {
            objc_getAssociatedObject(self, &eventBusKey) as? WebEventBus
        }
        set {
            objc_setAssociatedObject(self, &eventBusKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc
    private func addEventListener(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let eventBus = self.eventBus else {
                throw JSError.serviceNotFound
            }
            guard let identifier = try caller.decodeParamValue(String.self, for: "id") else {
                throw JSError.unexpectedServiceParam(paramKey: "id")
            }
            guard let name = try caller.decodeParamValue(String.self, for: "name") else {
                throw JSError.unexpectedServiceParam(paramKey: "name")
            }
            let handler = try caller.decodeParamValue(JSFunction.self, for: "handler")
            eventBus.addListener(.init(identifier: identifier, name: name, handler: { data in
                Task { @MainActor in
                    _ = try await handler?.call(param: data as? [String: Any])
                }
            }))
            return nil
        }
    }
    
    @objc
    private func removeEventListener(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let eventBus = self.eventBus else {
                throw JSError.serviceNotFound
            }
            let identifier = try caller.decodeParamValue(String.self, for: "id")
            guard let name = try caller.decodeParamValue(String.self, for: "name") else {
                throw JSError.unexpectedServiceParam(paramKey: "name")
            }
            eventBus.removeEventListener(identifier, name)
            return nil
        }
    }
    
    @objc
    private func dispatchEvent(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let eventBus = self.eventBus else {
                throw JSError.serviceNotFound
            }
            guard let name = try caller.decodeParamValue(String.self, for: "name") else {
                throw JSError.unexpectedServiceParam(paramKey: "name")
            }
            let data = try caller.decodeParamValue([String: Any].self, for: "data")
            eventBus.dispatchEvent(name, data: data ?? [:])
            return nil
        }
    }
}
