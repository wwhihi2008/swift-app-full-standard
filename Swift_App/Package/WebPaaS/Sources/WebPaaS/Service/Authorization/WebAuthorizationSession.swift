//
//  WebAuthorizationSession.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/15.
//

import Foundation
import AVFoundation
import Photos

@MainActor
open class WebAuthorizationSession {
    public init() { }
    
    open func requestMicrophoneAuthorization() async -> Bool {
        if #available(iOS 17.0, *) {
            return await AVAudioApplication.requestRecordPermission()
        } else {
            return AVAudioSession.sharedInstance().recordPermission == .granted
        }
    }
    
    open func requestCameraAuthorization() -> Bool {
        return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }
    
    open func requestPhotoAuthorization() async -> Bool {
        return await PHPhotoLibrary.requestAuthorization(for: .readWrite) == .authorized
    }
}
