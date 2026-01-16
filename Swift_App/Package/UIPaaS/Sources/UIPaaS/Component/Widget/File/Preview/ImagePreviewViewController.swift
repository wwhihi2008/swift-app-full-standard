//
//  ImagePreviewViewController.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/25.
//

import UIKit

@MainActor
open class ImagePreviewViewController: UIViewController, UIScrollViewDelegate {
    open var url: URL?
    
    open var image: UIImage? {
        return imageView.image
    }
    
    private lazy var scrollView: UIScrollView = {
        let instance = UIScrollView()
        instance.delegate = self
        instance.showsHorizontalScrollIndicator = false
        instance.showsVerticalScrollIndicator = false
        instance.minimumZoomScale = 0.5
        instance.maximumZoomScale = 5
        return instance
    }()
    
    private lazy var imageView: UIImageView = {
        let instance = UIImageView()
        instance.contentMode = .scaleAspectFit
        return instance
    }()
    
    private lazy var dismissGestureRecognizer: UITapGestureRecognizer = {
        let instance = UITapGestureRecognizer(target: self, action: #selector(self.dismissGestureDidTrigger))
        return instance
    }()
    
    @objc
    private func dismissGestureDidTrigger() {
        dismiss(animated: true)
    }
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     scrollView.topAnchor.constraint(equalTo: view.topAnchor),
                                     scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                                     scrollView.contentLayoutGuide.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier: 1),
                                     scrollView.contentLayoutGuide.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier: 1)])
        
        scrollView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                                     imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                                     imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                                     imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor)])
        
        view.addGestureRecognizer(dismissGestureRecognizer)
        
        if let url = url {
            Task {
                view.beginLoading()
                do {
                    let data = try await ImageURLSession.shared.downloadURL(url)
                    imageView.image = .init(data: data)
                } catch {
                    view.window?.toast("图片加载失败")
                }
                view.endLoading()
            }
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
