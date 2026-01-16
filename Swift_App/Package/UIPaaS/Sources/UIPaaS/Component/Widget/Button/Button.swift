//
//  Button.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/23.
//

import UIKit

@MainActor
extension UIButton {
    public static func primary() -> UIButton {
        let instance = UIButton(type: .custom)
        instance.backgroundColor = .hex_1d1d1f
        instance.setTitleColor(.white, for: .normal)
        instance.titleLabel?.font = .sys_14_semibold
        instance.layer.cornerRadius = 4
        instance.layer.masksToBounds = true
        instance.throttle = true
        return instance
    }
    
    public static func secondary() -> UIButton {
        let instance = UIButton(type: .custom)
        instance.backgroundColor = .white
        instance.setTitleColor(.hex_1d1d1f, for: .normal)
        instance.titleLabel?.font = .sys_14_semibold
        instance.layer.cornerRadius = 4
        instance.layer.masksToBounds = true
        instance.layer.borderWidth = 1
        instance.layer.borderColor = UIColor.hex_1d1d1f.cgColor
        instance.throttle = true
        return instance
    }
}
