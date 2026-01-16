//
//  WebLocationSession.swift
//  WebPaaS
//
//  Created by wuwei on 2025/9/16.
//

import Foundation
import CoreLocation

open class WebLocationSession: NSObject, CLLocationManagerDelegate {
    open private(set) var location: CLLocation?
    
    private lazy var locationManager: CLLocationManager = {
        let instance = CLLocationManager()
        instance.delegate = self
        return instance
    }()
    
    open func start() {
        locationManager.startUpdatingLocation()
    }
    
    open func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }
}
