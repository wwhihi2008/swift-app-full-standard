//
//  UIViewController+Document.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/17.
//

import UIKit
import UniformTypeIdentifiers

nonisolated(unsafe)
private var pickerViewControllerDelegateObjectKey: Void?

@MainActor
extension UIViewController {
    public func pickDocuments(forOpeningContentTypes contentTypes: [UTType]) async -> [URL] {
        return await withCheckedContinuation { continuation in
            Task {
                let controller = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes)
                let delegateObject = UIDocumentPickerViewControllerDelegateObject()
                delegateObject.completion = { results in
                    continuation.resume(returning: results)
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
private class UIDocumentPickerViewControllerDelegateObject: NSObject, UIDocumentPickerDelegate {
    var completion: (([URL]) -> Void)?
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        controller.dismiss(animated: true) {
            self.completion?(urls)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true) {
            self.completion?([])
        }
    }
}
