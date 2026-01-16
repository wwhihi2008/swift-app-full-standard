//
//  FileUploadTask.swift
//  UIPaaS
//
//  Created by wuwei on 2025/8/4.
//

import Foundation
import UniformTypeIdentifiers
import OSS

@MainActor
open class FileUploadTask: @unchecked Sendable {
    private enum DataSource {
        case data(data: Data, contentType: UTType)
        case url(url: URL)
    }
    
    convenience init(data: Data, contentType: UTType) {
        self.init(dataSource: .data(data: data, contentType: contentType))
    }
    
    convenience init(url: URL) {
        self.init(dataSource: .url(url: url))
    }
    
    private init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    private var dataSource: DataSource
    
    open func upload() async throws -> OSSFile {
        switch dataSource {
        case .data(let data, let contentType):
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appending(path: UUID().uuidString).appendingPathExtension(for: contentType)
            try data.write(to: tempURL)
            defer {
                Task.detached {
                    try? FileManager().removeItem(at: tempURL)
                }
            }
            return try await uploadURL(tempURL)
        case .url(let url):
            return try await uploadURL(url)
        }
    }
    
    private func uploadURL(_ url: URL) async throws -> OSSFile {
        try await OSSSession.shared.upload(file: url)
    }
}
