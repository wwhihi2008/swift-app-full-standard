//
//  FileUploadPicker.swift
//  UIPaaS
//
//  Created by wuwei on 2025/8/1.
//

import UIKit
import UniformTypeIdentifiers
import PhotosUI

@MainActor
open class FileUploadPicker { }

@MainActor
open class FileUploadCameraPicker: FileUploadPicker {
    public enum FileType {
        case photo
        case video
    }
    
    public init(fileType: FileType, sizeLimit: Int = 0) {
        self.fileType = fileType
        self.sizeLimit = sizeLimit
    }
    
    open var fileType: FileType = .photo
    
    open var sizeLimit: Int = 0    
}

@MainActor
open class FileUploadPhotosPicker: FileUploadPicker {
    public init(filter: PHPickerFilter, selectionLimit: Int = 0, sizeLimits: [PHAssetMediaType : Int] = [:]) {
        self.filter = filter
        self.selectionLimit = selectionLimit
        self.sizeLimits = sizeLimits
    }
    
    open var filter: PHPickerFilter
    
    open var selectionLimit: Int
    
    open var sizeLimits: [PHAssetMediaType: Int]
}

@MainActor
open class FileUploadDocumentPicker: FileUploadPicker {
    public init(utis: [UTType], sizeLimit: Int = 0) {
        self.utis = utis
        self.sizeLimit = sizeLimit
    }
    
    open var utis: [UTType]
    
    open var sizeLimit: Int
}
