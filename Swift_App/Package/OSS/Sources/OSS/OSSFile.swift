//
//  OSSFile.swift
//  OSS
//
//  Created by wuwei on 2025/6/17.
//

import UIKit
import UniformTypeIdentifiers

public class OSSFile: @unchecked Sendable {
    public var fileKey: String?    //文件key
    public var fileName: String?    //文件名称
    public var fileSize: Int?    //文件大小
    public var fileType: String?    //文件类型
    public var fileUrl: URL?    //文件访问
    
    public init(fileKey: String? = nil, fileName: String? = nil, fileSize: Int? = nil, fileType: String? = nil, fileUrl: URL? = nil) {
        self.fileKey = fileKey
        self.fileName = fileName
        self.fileSize = fileSize
        self.fileType = fileType
        self.fileUrl = fileUrl
    }
    
    public var isImage: Bool {
        if let mimeType = fileType, let type = UTType(mimeType: mimeType), type.conforms(to: .image) {
            return true
        }
        return false
    }
}
