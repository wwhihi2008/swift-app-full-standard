//
//  LoginViewController.swift
//  AuthApplication
//
//  Created by wuwei on 2025/6/25.
//

import UIKit
import UIPaaS
import SSO

class LoginViewController: UIViewController {
    private lazy var button: UIButton = {
        let instance = UIButton.primary()
        instance.setTitle("登录", for: .normal)
        instance.addTarget(self, action: #selector(self.buttonDidClick), for: .touchUpInside)
        return instance
    }()
    
    @objc
    private func buttonDidClick() {
        login()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                                     button.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)])
    }
    
    private func login() {
        Task {
            view.beginLoading()
            do {
                _ = try await SSOSession.shared.login(username: "18606531907", password: "123456a")
            } catch {
                view.window?.toast(error.localizedDescription)
            }
            view.endLoading()
        }
    }
}
