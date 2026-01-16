//
//  ImageURLSession.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/25.
//

import UIKit

@MainActor
open class ImageURLSession: @unchecked Sendable {
    public static let shared: ImageURLSession = .init()
    
    open private(set) var urlCache: URLCache = .init(memoryCapacity: 10 * 1024 * 1024,
                                                     diskCapacity: 100 * 1024 * 1024,
                                                     directory: FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "image"))
    
    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = urlCache
        let instance = URLSession(configuration: configuration)
        return instance
    }()
    
    open func downloadURL(_ url: URL) async throws -> Data {
        let request = URLRequest(url: url)
        let (data, response) = try await urlSession.data(for: request)
        let cachedResponse = CachedURLResponse(response: response, data: data)
        urlCache.storeCachedResponse(cachedResponse, for: request)
        return data
    }
    
    open func cancelAllDownloadTasks() {
        Task {
            await urlSession.allTasks.forEach { task in
                task.cancel()
            }
        }
    }
}
