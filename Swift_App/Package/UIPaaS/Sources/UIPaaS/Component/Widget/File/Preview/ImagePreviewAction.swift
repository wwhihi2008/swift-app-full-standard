//
//  ImagePreviewAction.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/25.
//

import UIKit

@MainActor
open class ImagePreviewAction: NSObject {
    open var icon: UIImage?
    open var handler: ((_ url: URL?, _ image: UIImage?) -> Void)?
    
    public init(icon: UIImage? = nil, handler: ((_: URL?, _: UIImage?) -> Void)? = nil) {
        self.icon = icon
        self.handler = handler
    }
}

@MainActor
extension ImagePreviewAction {
    func button() -> UIButton {
        let instance = UIButton(type: .custom)
        instance.backgroundColor = .mask
        instance.setImage(icon, for: .normal)
        instance.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([instance.widthAnchor.constraint(equalToConstant: 32),
                                     instance.heightAnchor.constraint(equalToConstant: 32)])
        instance.layer.cornerRadius = 16
        instance.layer.masksToBounds = true
        return instance
    }
}

@MainActor
extension ImagePreviewAction {
    public static func downloadAction() -> ImagePreviewAction {
        let instance = ImagePreviewAction(icon: .icon(named: IconName.icon_xiazai.rawValue, fontSize: 24, color: .hex_999999))
        instance.handler = { [weak instance] _, image in
            guard let image = image, let instance = instance else {
                return
            }
            UIImageWriteToSavedPhotosAlbum(image, instance, #selector(instance.save(image:didFinishSavingWithError:contextInfo:)), nil)
        }
        return instance
    }
    
    @objc
    private func save(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        guard let window = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.keyWindow else {
            return
        }
        if let error = error {
            window.toast(error.localizedDescription)
        } else {
            window.toast("保存成功")
        }
    }
}
