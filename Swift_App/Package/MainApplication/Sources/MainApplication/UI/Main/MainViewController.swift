//
//  MainViewController.swift
//  MainApplication
//
//  Created by wuwei on 2025/6/26.
//

import UIKit
import UIPaaS
import URLRoute

class MainViewController: UITabBarController {
    private lazy var homeViewController: UIViewController = {
        let instance = HomeViewController()
        instance.tabBarItem = .init(title: "首页",
                                    image: .icon(named: IconName.icon_home_7_fill.rawValue, fontSize: 20, color: .hex_cccccc),
                                    selectedImage: nil)
        return UINavigationController(rootViewController: instance)
    }()
    
    private lazy var approvalOrderListViewController: UIViewController = {
        let url = URL.appBaseURL.appending(path: "approvalOrderList")
        guard let instance = URLRouter.shared.route(for: url)?.viewController else {
            return UIViewController()
        }
        instance.tabBarItem = .init(title: "车贷业务",
                                    image: .icon(named: IconName.icon_service_fill.rawValue, fontSize: 20, color: .hex_cccccc),
                                    selectedImage: nil)
        return UINavigationController(rootViewController: instance)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.backgroundColor = .white
        tabBar.tintColor = .hex_1d1d1f
        tabBar.unselectedItemTintColor = .hex_cccccc
        initTabs()
    }
    
    private func initTabs() {
        viewControllers = [homeViewController, approvalOrderListViewController]
    }
}
