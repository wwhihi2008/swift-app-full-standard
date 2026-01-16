//
//  UIViewController+Camera.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/23.
//

import UIKit
import AVFoundation
import UniformTypeIdentifiers

nonisolated(unsafe)
private var imagePickerControllerDelegateObjectKey: Void?

@MainActor
extension UIViewController {
    public func cameraCapturePhoto() async -> (image: UIImage?, url: URL?) {
        return await withCheckedContinuation { continuation in
            Task {
                guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                    alertCameraAuthorizationGuide()
                    return
                }
                
                let controller = UIImagePickerController()
                controller.sourceType = .camera
                controller.cameraCaptureMode = .photo
                let delegateObject = UIImagePickerControllerDelegatePhotoObject()
                delegateObject.completion = { image, url in
                    continuation.resume(returning: (image, url))
                }
                objc_setAssociatedObject(self, &imagePickerControllerDelegateObjectKey, delegateObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                controller.delegate = delegateObject
                controller.modalPresentationStyle = .overFullScreen
                present(controller, animated: true)
            }
        }
    }
    
    public func cameraCaptureVideo() async -> URL? {
        return await withCheckedContinuation { continuation in
            Task {
                guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                    alertCameraAuthorizationGuide()
                    return
                }
                
                let controller = UIImagePickerController()
                controller.sourceType = .camera
                controller.mediaTypes = [UTType.movie.identifier]
                let delegateObject = UIImagePickerControllerDelegateVideoObject()
                delegateObject.completion = { result in
                    continuation.resume(returning: result)
                }
                objc_setAssociatedObject(self, &imagePickerControllerDelegateObjectKey, delegateObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                controller.delegate = delegateObject
                controller.modalPresentationStyle = .overFullScreen
                present(controller, animated: true)
            }
        }
    }
}

@MainActor
private class UIImagePickerControllerDelegatePhotoObject: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var completion: (@MainActor (UIImage?, URL?) -> Void)?
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.completion?(nil, nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            self.completion?(info[.originalImage] as? UIImage, info[.imageURL] as? URL)
        }
    }
}

@MainActor
private class UIImagePickerControllerDelegateVideoObject: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var completion: (@MainActor (URL?) -> Void)?
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.completion?(nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            self.completion?(info[.mediaURL] as? URL)
        }
    }
}
