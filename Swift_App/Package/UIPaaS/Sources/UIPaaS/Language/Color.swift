//
//  Color.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/20.
//

import UIKit

extension UIColor {
    public static let hex_1d1d1f: UIColor = .init(hex: 0x1d1d1f, alpha: 1)
    public static let hex_999999: UIColor = .init(hex: 0x999999, alpha: 1)
    public static let hex_cccccc: UIColor = .init(hex: 0xcccccc, alpha: 1)
    public static let hex_f6f6f9: UIColor = .init(hex: 0xf6f6f9, alpha: 1)
    
    public static let mask: UIColor = .black.withAlphaComponent(0.2)
}

extension UIColor {
    public convenience init(hex: UInt32, alpha: CGFloat) {
        let red = (hex & 0xFF0000) >> 16;
        let green = (hex & 0x00FF00) >> 8;
        let blue = hex & 0x0000FF;
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}
