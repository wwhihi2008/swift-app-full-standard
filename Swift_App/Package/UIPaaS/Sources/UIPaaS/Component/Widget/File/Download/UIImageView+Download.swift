//
//  UIImageView+Download.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/24.
//

import UIKit

nonisolated(unsafe)
private var downloadTaskKey: Void?

@MainActor
extension UIImageView {
    public func downloadURL(_ url: URL, failureImage: UIImage? = .failure) {
        if let oldTask = objc_getAssociatedObject(self, &downloadTaskKey) as? Task<(), Never> {
            oldTask.cancel()
        }
        let task = Task {
            beginLoading()
            do {
                let data = try await ImageURLSession.shared.downloadURL(url)
                image = .init(data: data)
            } catch {
                if !Task.isCancelled {
                    image = failureImage
                }
            }
            endLoading()
        }
        objc_setAssociatedObject(self, &downloadTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public func cancelDownload() {
        if let task = objc_getAssociatedObject(self, &downloadTaskKey) as? Task<(), Never> {
            task.cancel()
        }
    }
}
