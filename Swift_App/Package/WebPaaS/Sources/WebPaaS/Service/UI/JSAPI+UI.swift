//
//  JSAPI+UI.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/21.
//

import UIKit
import UIPaaS

@MainActor
extension JSAPIBus {
    @objc
    private func showToast(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            let content = try caller.decodeParamValue(String.self, for: "content")
            self.webView?.window?.toast(content)
            return nil
        }
    }
}
