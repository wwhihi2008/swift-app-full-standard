//
//  JSAPI+Route.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/11.
//

import Foundation

nonisolated(unsafe)
private var routerKey: Void?

@MainActor
extension JSAPIBus {
    var webRouter: WebRouter? {
        get {
            objc_getAssociatedObject(self, &routerKey) as? WebRouter
        }
        set {
            objc_setAssociatedObject(self, &routerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc
    private func navigateTo(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let webRouter = self.webRouter else {
                throw JSError.serviceNotFound
            }
            guard let url = try caller.decodeParamValue(String.self, for: "url"), let url = URL(string: url) else {
                throw JSError.unexpectedServiceParam(paramKey: "url")
            }
            webRouter.navigateTo(url)
            return nil
        }
    }
    
    @objc
    private func navigateBack(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let webRouter = self.webRouter else {
                throw JSError.serviceNotFound
            }
            webRouter.navigateBack()
            return nil
        }
    }
}
