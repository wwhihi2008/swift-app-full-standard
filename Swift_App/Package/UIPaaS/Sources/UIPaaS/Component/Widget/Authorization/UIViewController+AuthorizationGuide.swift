//
//  UIViewController+AuthorizationGuide.swift
//  UIPaaS
//
//  Created by wuwei on 2025/8/18.
//

import UIKit

extension UIViewController {
    public func alertCameraAuthorizationGuide() {
        let alert = AlertController(title: "开启相机权限", message: "前往设置")
        alert.actions = [.init(cancelHandler: nil),
                         .init(confirmHandler: {
                             if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                                 UIApplication.shared.open(url)
                             }
                         })]
        present(alert, animated: true)
    }
    
    public func alertPhotoAuthorizationGuide() {
        let alert = AlertController(title: "开启相册权限", message: "前往设置")
        alert.actions = [.init(cancelHandler: nil),
                         .init(confirmHandler: {
                             if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                                 UIApplication.shared.open(url)
                             }
                         })]
        present(alert, animated: true)
    }
    
    public func alertMicrophoneAuthorizationGuide() {
        let alert = AlertController(title: "开启麦克风权限", message: "前往设置")
        alert.actions = [.init(cancelHandler: nil),
                         .init(confirmHandler: {
                             if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                                 UIApplication.shared.open(url)
                             }
                         })]
        present(alert, animated: true)
    }
}
