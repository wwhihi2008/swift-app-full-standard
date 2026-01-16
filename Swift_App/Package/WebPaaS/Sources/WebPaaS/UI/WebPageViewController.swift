//
//  WebPageViewController.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/7.
//

import UIKit
import WebKit
import UIPaaS

@MainActor
open class WebPageViewController: URLWebViewController {
    public lazy var jsAPIBus: JSAPIBus = {
        let instance = JSAPIBus()
        instance.webView = webView
        return instance
    }()
    
    open var authenticationSession: WebAuthenticationSession? {
        didSet {
            jsAPIBus.authenticationSession = authenticationSession
        }
    }
    
    open var eventBus: WebEventBus? {
        didSet {
            jsAPIBus.eventBus = eventBus
        }
    }
    
    open var authorizationSession: WebAuthorizationSession? {
        didSet {
            jsAPIBus.authorizationSession = authorizationSession
        }
    }
    
    open var locationSession: WebLocationSession? {
        didSet {
            jsAPIBus.locationSession = locationSession
        }
    }
    
    private lazy var webRouter: WebRouter = {
        let instance = WebRouter()
        instance.delegate = self
        return instance
    }()
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        jsAPIBus.webRouter = webRouter
        let jsController = JSController()
        jsController.apiSet = jsAPIBus
        webView.jsController = jsController
    }
    
    open override func loadURL() {
        guard var url = url else {
            return
        }
        if let token = authenticationSession?.token {
            url.append(queryItems: [.init(name: "token", value: token)])
        }
        webView.load(.init(url: url))
    }
}

extension WebPageViewController: WebRoute {
    public func navigateTo(_ pageURL: URL) {
        let newPageViewController = WebPageViewController()
        newPageViewController.url = pageURL
        newPageViewController.authenticationSession = authenticationSession
        newPageViewController.eventBus = eventBus
        newPageViewController.authorizationSession = authorizationSession
        newPageViewController.locationSession = locationSession
        navigationController?.pushViewController(newPageViewController, animated: true)
    }
    
    public func navigateBack() {
        navigationController?.popViewController(animated: true)
    }
}
