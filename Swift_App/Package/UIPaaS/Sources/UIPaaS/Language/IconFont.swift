//
//  IconFont.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/20.
//

import UIKit

@MainActor
open class IconFont: @unchecked Sendable {
    public init?(ttfURL: URL, descriptionURL: URL) {
        guard let fontData = NSData(contentsOf: ttfURL),
              let dataProvider = CGDataProvider(data: fontData),
              let font = CGFont(dataProvider),
              let descriptionData = try? Data(contentsOf: descriptionURL),
              let description = try? JSONDecoder().decode(IconFontDescription.self, from: descriptionData),
              CTFontManagerRegisterGraphicsFont(font, nil) else {
            return nil
        }
        
        self.ttfURL = ttfURL
        self.description = description
        // MARK: 生成case的工具
//        description.glyphs.forEach { element in
//            let name = element.name
//            print("case \(name.replacingOccurrences(of: "-", with: "_")) = \"\(name)\"")
//        }
    }
    
    public let ttfURL: URL
    public let description: IconFontDescription
    
    public func icon(named name: String, fontSize: CGFloat, color: UIColor?) -> UIImage? {
        guard let unicodeString = description.glyphs.first(where: { glyph in
            return glyph.name == name
        })?.unicode,
              let unicodeScalar = Int(unicodeString, radix: 16).flatMap({ value in
                  return Unicode.Scalar(value).map { String($0) }
              }),
              fontSize > 0 else {
            return nil
        }
        
        let font = UIFont(name: description.font_family, size: fontSize)
        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[.font] = font
        attributes[.foregroundColor] = color
        let attributedText = NSAttributedString(string: unicodeScalar, attributes: attributes)
        
        let rect = attributedText.boundingRect(with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), context: nil)
        
        UIGraphicsBeginImageContextWithOptions(rect.size,
                                               false,
                                               UIScreen.main.scale)
        attributedText.draw(at: .zero)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

public struct IconFontDescription: Codable {
    public var id: String
    public var name: String
    public var font_family: String
    public var css_prefix_text: String
    public var description: String
    public var glyphs: [Glyph]
}

extension IconFontDescription {
    public struct Glyph: Codable {
        public var icon_id: String
        public var name: String
        public var font_class: String
        public var unicode: String
        public var unicode_decimal: Int
    }
}
