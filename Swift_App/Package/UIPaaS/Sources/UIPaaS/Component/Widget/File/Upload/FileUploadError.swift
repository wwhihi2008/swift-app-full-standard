//
//  FileUploadError.swift
//  UIPaaS
//
//  Created by wuwei on 2025/8/4.
//

import Foundation

public enum FileUploadError: LocalizedError {
    case sizeOverflow(_ url: URL?, sizeLimit: Int)
    
    public var errorDescription: String? {
        return "内容大小超过限制"
    }
}
