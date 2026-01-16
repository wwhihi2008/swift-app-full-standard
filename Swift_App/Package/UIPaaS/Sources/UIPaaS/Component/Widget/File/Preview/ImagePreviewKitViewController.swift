//
//  ImagePreviewKitViewController.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/24.
//

import UIKit

nonisolated(unsafe)
private var buttonActionKey: Void?

@MainActor
open class ImagePreviewKitViewController: UINavigationController {
    open var urls: [URL?] = []
    
    open var startIndex: Int = 0
    
    open var actions: [ImagePreviewAction] = [.downloadAction()]
    
    private lazy var previewViewController: ImagesPreviewViewController = {
        let instance = ImagesPreviewViewController()
        return instance
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let instance = UIStackView()
        instance.axis = .horizontal
        instance.alignment = .center
        instance.distribution = .fill
        instance.spacing = 8
        return instance
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.backgroundColor = .white.withAlphaComponent(0.5)
        
        previewViewController.startIndex = startIndex
        previewViewController.urls = urls
        setViewControllers([previewViewController], animated: false)
        view.backgroundColor = previewViewController.view.backgroundColor
        
        view.addSubview(actionsStackView)
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([actionsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                                     actionsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
                                     actionsStackView.heightAnchor.constraint(equalToConstant: 44)])

        actions.forEach { action in
            let button = action.button()
            button.addTarget(self, action: #selector(self.buttonDidClick), for: .touchUpInside)
            objc_setAssociatedObject(button, &buttonActionKey, action.handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            actionsStackView.addArrangedSubview(button)
        }
    }
    
    @objc
    private func buttonDidClick(_ sender: UIButton) {
        if let handler = objc_getAssociatedObject(sender, &buttonActionKey) as? ((_ url: URL?, _ image: UIImage?) -> Void) {
            let index = previewViewController.currentIndex
            let url = (index >= 0 && index < urls.count) ? urls[index] : nil
            let image = previewViewController.currentImage
            handler(url, image)
        }
    }   
}
