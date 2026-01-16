//
//  Border.swift
//  UIPaaS
//
//  Created by wuwei on 2025/7/7.
//

import UIKit

public struct Border {
    public enum Position: Int {
        case leading
        case trailing
        case top
        case bottom
    }
    
    public var position: Position
    public var width: CGFloat
    public var color: UIColor
    
    public init(position: Position, width: CGFloat, color: UIColor) {
        self.position = position
        self.width = width
        self.color = color
    }
}

extension UIView {
    public func addBorders(_ borders: [Border]) {
        borders.forEach { border in
            let view = UIView()
            view.backgroundColor = border.color
            addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            switch border.position {
            case .leading:
                NSLayoutConstraint.activate([view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                             view.widthAnchor.constraint(equalToConstant: border.width),
                                             view.topAnchor.constraint(equalTo: topAnchor),
                                             view.bottomAnchor.constraint(equalTo: bottomAnchor)])
                break
            case .trailing:
                NSLayoutConstraint.activate([view.trailingAnchor.constraint(equalTo: trailingAnchor),
                                             view.widthAnchor.constraint(equalToConstant: border.width),
                                             view.topAnchor.constraint(equalTo: topAnchor),
                                             view.bottomAnchor.constraint(equalTo: bottomAnchor)])
                break
            case .top:
                NSLayoutConstraint.activate([view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                             view.trailingAnchor.constraint(equalTo: trailingAnchor),
                                             view.topAnchor.constraint(equalTo: topAnchor),
                                             view.heightAnchor.constraint(equalToConstant: border.width)])
                break
            case .bottom:
                NSLayoutConstraint.activate([view.leadingAnchor.constraint(equalTo: leadingAnchor),
                                             view.trailingAnchor.constraint(equalTo: trailingAnchor),
                                             view.bottomAnchor.constraint(equalTo: bottomAnchor),
                                             view.heightAnchor.constraint(equalToConstant: border.width)])
                break
            }

        }
    }
}
