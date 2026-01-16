//
//  UIViewController+FileUpload.swift
//  UIPaaS
//
//  Created by wuwei on 2025/8/4.
//

import UIKit
import PhotosUI

@MainActor
extension UIViewController {
    public func uploadFile(with pickers: [FileUploadPicker]) async throws -> [FileUploadTask] {
        return try await withCheckedThrowingContinuation { continuation in
            let actionSheet = ActionSheetController(title: nil)
            actionSheet.actions = pickers.compactMap({ picker in
                if let picker = picker as? FileUploadCameraPicker {
                    return .init(title: "拍照", style: .default) { [weak self] in
                        guard let self = self else {
                            return
                        }
                        Task {
                            do {
                                continuation.resume(returning: try await self.cameraCapture(picker))
                            } catch {
                                continuation.resume(throwing: error)
                            }
                        }
                    }
                }
                if let picker = picker as? FileUploadPhotosPicker {
                    return .init(title: "相册", style: .default) { [weak self] in
                        guard let self = self else {
                            return
                        }
                        Task {
                            do {
                                continuation.resume(returning: try await self.pickPhotos(picker))
                            } catch {
                                continuation.resume(throwing: error)
                            }
                        }
                    }
                }
                if let picker = picker as? FileUploadDocumentPicker {
                    return .init(title: "文件", style: .default) { [weak self] in
                        guard let self = self else {
                            return
                        }
                        Task {
                            do {
                                continuation.resume(returning: try await self.pickDocument(picker))
                            } catch {
                                continuation.resume(throwing: error)
                            }
                        }
                    }
                }
                return nil
            }) + [.init(title: "取消", style: .cancel)]
            present(actionSheet, animated: true)
        }
    }
    
    private func cameraCapture(_ picker: FileUploadCameraPicker) async throws -> [FileUploadTask] {
        if picker.fileType == .photo {
            let result = await cameraCapturePhoto()
            guard let image = result.image, let jpeg = image.jpegData(compressionQuality: 0.7) else {
                return []
            }
            if picker.sizeLimit > 0, jpeg.count > picker.sizeLimit {
                throw FileUploadError.sizeOverflow(nil, sizeLimit: picker.sizeLimit)
            }
            return [.init(data: jpeg, contentType: .jpeg)]
        } else if picker.fileType == .video {
            guard let url = await cameraCaptureVideo() else {
                return []
            }
            if picker.sizeLimit > 0, let size = try FileManager.default.attributesOfItem(atPath: url.path())[.size] as? Int, size > picker.sizeLimit {
                throw FileUploadError.sizeOverflow(url, sizeLimit: picker.sizeLimit)
            }
            return [.init(url: url)]
        } else {
            return []
        }
    }
    
    private func pickPhotos(_ picker: FileUploadPhotosPicker) async throws -> [FileUploadTask] {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = picker.filter
        configuration.selectionLimit = picker.selectionLimit
        let assets = await pickPhotos(configuration: configuration)
        guard !assets.isEmpty else {
            return []
        }
        return try await withThrowingTaskGroup(of: FileUploadTask.self, returning: [FileUploadTask].self) { @MainActor group in
            assets.enumerated().forEach { element in
                let index = element.offset
                let asset = element.element
                group.addTask {
                    return try await withCheckedThrowingContinuation { continuation in
                        if asset.mediaType == .image {
                            let options = PHImageRequestOptions()
                            options.isNetworkAccessAllowed = true
                            PHImageManager.default().requestImage(for: asset,
                                                                  targetSize: PHImageManagerMaximumSize,
                                                                  contentMode: .aspectFit,
                                                                  options: options) { image, info in
                                guard let info = info, let degrade = info[PHImageResultIsDegradedKey] as? Bool, !degrade, let image = image, let jpeg = image.jpegData(compressionQuality: 0.7) else {
                                    return
                                }
                                Task { @MainActor in
                                    if let sizeLimit = picker.sizeLimits[.image], sizeLimit > 0, jpeg.count > sizeLimit {
                                        continuation.resume(throwing: FileUploadError.sizeOverflow(nil, sizeLimit: sizeLimit))
                                        return
                                    }
                                    let task = FileUploadTask(data: jpeg, contentType: .jpeg)
                                    task.order = index
                                    continuation.resume(returning: task)
                                }
                            }
                        } else if asset.mediaType == .video {
                            PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { asset, _, _ in
                                guard let urlAsset = asset as? AVURLAsset else {
                                    return
                                }
                                Task { @MainActor in
                                    do {
                                        let url = urlAsset.url
                                        if let sizeLimit = picker.sizeLimits[.video], sizeLimit > 0, let size = try FileManager.default.attributesOfItem(atPath: url.path())[.size] as? Int, size > sizeLimit {
                                            continuation.resume(throwing: FileUploadError.sizeOverflow(nil, sizeLimit: sizeLimit))
                                            return
                                        }
                                        let task = FileUploadTask(url: url)
                                        task.order = index
                                        continuation.resume(returning: task)
                                    } catch {
                                        continuation.resume(throwing: error)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            var tasks: [FileUploadTask] = []
            for try await task in group {
                tasks.append(task)
            }
            // 注意排序
            return tasks.sorted { a, b in
                return (a.order ?? 0) < (b.order ?? 0)
            }
        }
    }
    
    private func pickDocument(_ picker: FileUploadDocumentPicker) async throws -> [FileUploadTask] {
        let urls = await pickDocuments(forOpeningContentTypes: picker.utis)
        return try urls.reduce([]) { partialResult, url in
            if picker.sizeLimit > 0, let size = try FileManager.default.attributesOfItem(atPath: url.path())[.size] as? Int, size > picker.sizeLimit {
                throw FileUploadError.sizeOverflow(url, sizeLimit: picker.sizeLimit)
            } else {
                return partialResult + [.init(url: url)]
            }
        }
    }
}

nonisolated(unsafe)
private var orderKey: Void?

extension FileUploadTask {
    fileprivate var order: Int? {
        get {
            return objc_getAssociatedObject(self, &orderKey) as? Int
        }
        set {
            objc_setAssociatedObject(self, &orderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
