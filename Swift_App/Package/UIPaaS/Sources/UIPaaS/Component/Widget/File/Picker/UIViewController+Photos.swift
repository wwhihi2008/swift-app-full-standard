//
//  UIViewController+Photos.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/17.
//

import UIKit
import PhotosUI

nonisolated(unsafe)
private var pickerViewControllerDelegateObjectKey: Void?

@MainActor
extension UIViewController {
    public static let defaultPhotosPickerConfiguration: PHPickerConfiguration = {
        var instance = PHPickerConfiguration()
        instance.filter = .images
        return instance
    }()
    
    public func pickPhotos(configuration: PHPickerConfiguration) async -> [PHAsset] {
        return await withCheckedContinuation { continuation in
            Task {
                let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
                guard status == .authorized || status == .limited else {
                    alertPhotoAuthorizationGuide()
                    return
                }
                
                let controller = PHPickerViewController(configuration: configuration)
                let delegateObject = PHPickerViewControllerDelegateObject()
                delegateObject.completion = { results in
                    var assets: [PHAsset] = []
                    PHAsset.fetchAssets(withLocalIdentifiers: results.compactMap({ result in
                        return result.assetIdentifier
                    }), options: nil).enumerateObjects { asset, _, _ in
                        assets.append(asset)
                    }
                    // 注意排序
                    continuation.resume(returning: assets.sorted(by: { a, b in
                        let aIndex = results.firstIndex { result in
                            return result.assetIdentifier == a.localIdentifier
                        }
                        let bIndex = results.firstIndex { result in
                            return result.assetIdentifier == b.localIdentifier
                        }
                        return (aIndex ?? 0) < (bIndex ?? 0)
                    }))
                }
                objc_setAssociatedObject(self, &pickerViewControllerDelegateObjectKey, delegateObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                controller.delegate = delegateObject
                controller.modalPresentationStyle = .overFullScreen
                present(controller, animated: true)
            }
        }
    }
}

@MainActor
private class PHPickerViewControllerDelegateObject: PHPickerViewControllerDelegate {
    var completion: (([PHPickerResult]) -> Void)?
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) {
            self.completion?(results)
        }
    }
}
