//
//  URLWebViewController.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/11.
//

import UIKit
import WebKit

@MainActor
open class URLWebViewController: UIViewController, WKNavigationDelegate {
    open var url: URL?
    
    public lazy var webView: WKWebView = {
        let instance = WKWebView(frame: .zero, configuration: .init())
        if #available(iOS 16.4, *) {
            instance.isInspectable = true
        } else {
            // Fallback on earlier versions
        }
        instance.navigationDelegate = self
        instance.scrollView.bouncesZoom = false
        instance.scrollView.maximumZoomScale = 1
        instance.scrollView.minimumZoomScale = 1
        return instance
    }()
    
    public lazy var progressView: UIProgressView = {
        let instance = UIProgressView()
        instance.tintColor = .hex_1d1d1f
        instance.trackTintColor = .clear
        instance.isHidden = true
        return instance
    }()
    
    public lazy var errorView: ErrorView = {
        let instance = ErrorView.dataError { [weak self] in
            guard let self = self else {
                return
            }
            self.loadURL()
        }
        instance.isHidden = true
        return instance
    }()
    
    private var keyValueObservations: [NSKeyValueObservation] = []
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                                     webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                                     webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                                     webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        webView.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([progressView.leadingAnchor.constraint(equalTo: webView.safeAreaLayoutGuide.leadingAnchor),
                                     progressView.trailingAnchor.constraint(equalTo: webView.safeAreaLayoutGuide.trailingAnchor),
                                     progressView.topAnchor.constraint(equalTo: webView.safeAreaLayoutGuide.topAnchor),
                                     progressView.heightAnchor.constraint(equalToConstant: 1)])
        
        view.addSubview(errorView)
        errorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                                     errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                                     errorView.topAnchor.constraint(equalTo: view.topAnchor),
                                     errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        let titleObservation = webView.observe(\.title, options: .new) { [weak self] _, value in
            guard let self = self else {
                return
            }
            Task { @MainActor in
                if self.title != nil {
                    return
                }
                self.navigationItem.title = value.newValue ?? ""
            }
        }
        keyValueObservations.append(titleObservation)
        
        let progressObservation = webView.observe(\.estimatedProgress, options: .new) { [weak self] _, value in
            guard let self = self else {
                return
            }
            Task { @MainActor in
                let progress = value.newValue ?? 0
                self.progressView.progress = Float(progress)
                self.progressView.isHidden = progress >= 1
            }
        }
        keyValueObservations.append(progressObservation)
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        _ = urlLoadOnce
    }
    
    private lazy var urlLoadOnce: Void = {
        loadURL()
    }()
    
    open func loadURL() {
        guard let url = url else {
            return
        }
        webView.load(.init(url: url))
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: any Error) {
        errorView.isHidden = false
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: any Error) {
        errorView.isHidden = false
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        errorView.isHidden = true
    }
}
