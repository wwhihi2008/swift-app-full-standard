//
//  WebRoute.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/11.
//

import UIKit

@MainActor
public protocol WebRoute: AnyObject {
    func navigateTo(_ pageURL: URL)
    func navigateBack()
}

@MainActor
open class WebRouter: WebRoute {
    public init() { }
    
    weak var delegate: WebRoute?
    
    public func navigateTo(_ pageURL: URL) {
        delegate?.navigateTo(pageURL)
    }
    
    public func navigateBack() {
        delegate?.navigateBack()
    }
}
