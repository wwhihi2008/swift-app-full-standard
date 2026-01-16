//
//  JSAPI+Media.swift
//  WebPaaS
//
//  Created by wuwei on 2025/8/18.
//

import UIKit
import UIPaaS

@MainActor
extension JSAPIBus {
    @objc
    private func saveImage(_ params: [String: Any]?) {
        JSAPICaller(params: params).call { caller in
            guard let url = try caller.decodeParamValue(String.self, for: "url"), let url = URL(string: url) else {
                throw JSError.unexpectedServiceParam(paramKey: "url")
            }
            let data = try await ImageURLSession.shared.downloadURL(url)
            guard let image = UIImage(data: data) else {
                throw JSError.imageSaveError
            }
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            return nil
        }
    }
}
