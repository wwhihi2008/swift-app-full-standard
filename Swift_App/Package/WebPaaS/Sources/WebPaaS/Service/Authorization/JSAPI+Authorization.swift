//
//  JSAPI+Authorization.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/15.
//

import Foundation

private enum AuthorizationType: String {
    case CAMERA
    case PHOTO
    case MICROPHONE
}

nonisolated(unsafe)
private var authorizationSessionKey: Void?

@MainActor
extension JSAPIBus {
    var authorizationSession: WebAuthorizationSession? {
        get {
            objc_getAssociatedObject(self, &authorizationSessionKey) as? WebAuthorizationSession
        }
        set {
            objc_setAssociatedObject(self, &authorizationSessionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc
    private func checkAuth(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let authorizationSession = self.authorizationSession else {
                throw JSError.serviceNotFound
            }
            guard let authType = try caller.decodeParamValue(String.self, for: "authType") else {
                return ["granted": false]
            }
            let granted = await {
                switch AuthorizationType(rawValue: authType) {
                case .CAMERA:
                    return authorizationSession.requestCameraAuthorization()
                case .PHOTO:
                    return await authorizationSession.requestPhotoAuthorization()
                case .MICROPHONE:
                    return await authorizationSession.requestMicrophoneAuthorization()
                default:
                    return false
                }
            }()
            return ["granted": granted]
        }
    }
    
    @objc
    private func showAuthGuide(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let webViewController = self.webView?.responderController else {
                throw JSError.serviceNotFound
            }
            guard let authType = try caller.decodeParamValue(String.self, for: "authType").flatMap({ string in
                return AuthorizationType(rawValue: string)
            }) else {
                throw JSError.unexpectedServiceParam(paramKey: "authType")
            }
            switch authType {
            case .CAMERA:
                webViewController.alertCameraAuthorizationGuide()
            case .PHOTO:
                webViewController.alertPhotoAuthorizationGuide()
            case .MICROPHONE:
                webViewController.alertMicrophoneAuthorizationGuide()
            }
            return nil
        }
    }
}
