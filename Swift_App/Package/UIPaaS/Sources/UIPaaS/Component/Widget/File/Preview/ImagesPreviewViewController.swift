//
//  ImagesPreviewViewController.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/25.
//

import UIKit

@MainActor
open class ImagesPreviewViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    public init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
        delegate = self
        dataSource = self
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
        dataSource = self
    }
    
    open var urls: [URL?] = []
    
    open var startIndex: Int = 0
    
    open var currentIndex: Int {
        return (viewControllers?.first as? ImagePreviewViewController)?.pageIndex ?? 0
    }
    
    open var currentImage: UIImage? {
        return (viewControllers?.first as? ImagePreviewViewController)?.image
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstPreviewViewController = ImagePreviewViewController()
        firstPreviewViewController.url = urls.count > startIndex ? urls[startIndex] : nil
        firstPreviewViewController.pageIndex = startIndex
        setViewControllers([firstPreviewViewController], direction: .forward, animated: false)
        
        view.backgroundColor = firstPreviewViewController.view.backgroundColor
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        updateTitle()
    }
    
    private func updateTitle() {
        navigationItem.title = "\(currentIndex + 1)/\(urls.count)"
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? ImagePreviewViewController)?.pageIndex, index > 0 else {
            return nil
        }
        let beforeIndex = index - 1
        let beforeViewController = ImagePreviewViewController()
        beforeViewController.url = urls[beforeIndex]
        beforeViewController.pageIndex = beforeIndex
        return beforeViewController
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = (viewController as? ImagePreviewViewController)?.pageIndex, index < urls.count - 1 else {
            return nil
        }
        let afterIndex = index + 1
        let afterViewController = ImagePreviewViewController()
        afterViewController.url = urls[afterIndex]
        afterViewController.pageIndex = afterIndex
        return afterViewController
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        updateTitle()
    }
}

nonisolated(unsafe)
private var pageIndexKey: Void?

extension ImagePreviewViewController {
    fileprivate var pageIndex: Int? {
        get {
            return objc_getAssociatedObject(self, &pageIndexKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &pageIndexKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
