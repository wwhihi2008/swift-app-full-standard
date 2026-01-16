//
//  AppViewController.swift
//  Swift_App
//
//  Created by wuwei on 2025/6/24.
//

import UIKit
import APIGateway
import OSS
import UIPaaS
import URLRoute
import SSO
import Directive
import AuthApplication
import MainApplication
import DDApplication

@MainActor
class AppViewController: UINavigationController {
    deinit {
        tasks.forEach { task in
            task.cancel()
        }
    }
    
    private lazy var authApplication: AuthApplication.Application = {
        let instance = AuthApplication.Application()
        return instance
    }()
    
    private lazy var mainApplication: MainApplication.Application = {
        let instance = MainApplication.Application()
        return instance
    }()
    
    private lazy var ddApplication: DDApplication.Application = {
        let instance = DDApplication.Application()
        return instance
    }()
    
    private var tasks: [Task<Void, Never>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        isNavigationBarHidden = true
        
        URLRouter.shared.nodes = [authApplication, mainApplication, ddApplication]
        
        tasks.append(Task { [unowned self] in
            let notifications = NotificationCenter.default.notifications(named: Directive.logoutNotification)
            for await _ in notifications.compactMap({ _ in
                return 0
            }) {
                self.logout()
            }
        })
        
        let token = SSOSession.shared.token
        APISession.shared.token = token
        OSSSession.shared.token = token
        tasks.append(Task { [unowned self] in
            for await _ in NotificationCenter.default.notifications(named: SSOSession.tokenDidUpdateNotification, object: SSOSession.shared) {
                let token = SSOSession.shared.token
                APISession.shared.token = token
                OSSSession.shared.token = token
                self.updateContent()
            }
        })
        
        Task {
            updateContent()
        }
    }
    
    private func updateContent() {
        if SSOSession.shared.token == nil {
            login()
            isLogining = true
        } else {
            isLogining = false
            goMain()
        }
    }
    
    private func goMain() {
        view.window?.endEditing(true)
        dismiss(animated: true)
        let url = URL.appBaseURL.appending(path: "main")
        guard let vc = URLRouter.shared.route(for: url)?.viewController else {
            return
        }
        setViewControllers([vc], animated: false)
    }
    
    private var isLogining = false
    
    private func login() {
        guard !isLogining else {
            return
        }
        let url = URL.appBaseURL.appending(path: "login")
        guard let vc = URLRouter.shared.route(for: url)?.viewController else {
            return
        }
        vc.modalPresentationStyle = .overFullScreen
        topPresentedViewController.present(vc, animated: true)
    }
    
    private func logout() {
        Task {
            view.window?.beginLoading()
            try? await SSOSession.shared.logout()
            view.window?.endLoading()
        }
    }
}

extension AppViewController {
    private var topPresentedViewController: UIViewController {
        var vc: UIViewController = self
        while let newVC = vc.presentedViewController {
            vc = newVC
        }
        return vc
    }
}
