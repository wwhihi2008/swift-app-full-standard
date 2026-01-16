//
//  JSAPI+Location.swift
//  WebPaaS
//
//  Created by wuwei on 2025/9/16.
//

import Foundation

nonisolated(unsafe)
private var locationSessionKey: Void?

@MainActor
extension JSAPIBus {
    var locationSession: WebLocationSession? {
        get {
            objc_getAssociatedObject(self, &locationSessionKey) as? WebLocationSession
        }
        set {
            objc_setAssociatedObject(self, &locationSessionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @objc
    private func startLocating(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let locationSession = self.locationSession else {
                throw JSError.serviceNotFound
            }
            locationSession.start()
            return nil
        }
    }
    
    @objc
    private func stopLocating(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let locationSession = self.locationSession else {
                throw JSError.serviceNotFound
            }
            locationSession.stop()
            return nil
        }
    }
    
    @objc
    private func getLocation(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let locationSession = self.locationSession else {
                throw JSError.serviceNotFound
            }
            
            if let location = locationSession.location {
                return ["type": "WGS-84",
                        "longitude": location.coordinate.longitude,
                        "latitude": location.coordinate.latitude]
            } else {
                return nil
            }
        }
    }
}
