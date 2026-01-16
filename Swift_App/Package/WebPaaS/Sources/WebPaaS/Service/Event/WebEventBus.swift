//
//  WebEventBus.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/7.
//

import Foundation

open class WebEventListener {
    public init(identifier: String, name: String, handler: (([AnyHashable : Any]) -> Void)? = nil) {
        self.identifier = identifier
        self.name = name
        self.handler = handler
    }
    
    open var identifier: String
    
    open var name: String
    
    open var handler: (([String: Any]) -> Void)?
}

@MainActor
open class WebEventBus {
    public init() { }
    
    private var listeners: [WebEventListener] = []
    
    func addListener(_ listener: WebEventListener) {
        listeners.append(listener)
    }
    
    func removeEventListener(_ identifier: String?, _ name: String) {
        listeners.removeAll { listener in
            if let identifier = identifier {
                return listener.identifier == identifier && listener.name == name
            } else {
                return listener.name == name
            }
        }
    }

    func dispatchEvent(_ name: String, data: [String: Any]) {
        listeners.forEach { listener in
            if listener.name == name {
                listener.handler?(data)
            }
        }
    }
}
