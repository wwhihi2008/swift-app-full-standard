//
//  DataPickerViewController.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/28.
//

import UIKit

@MainActor
open class ActionedPickerViewController: UIViewController {
    open lazy var actionBar: ActionBar = {
        let instance = ActionBar()
        return instance
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(actionBar)
        actionBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([actionBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                     actionBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                                     actionBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
    }
}
