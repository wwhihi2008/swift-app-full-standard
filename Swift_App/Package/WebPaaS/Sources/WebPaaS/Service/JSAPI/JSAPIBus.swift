//
//  JSAPIBus.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/7.
//

import Foundation
import WebKit

@MainActor
open class JSAPIBus: NSObject, JSAPISet {
    public weak var webView: WKWebView?
}
