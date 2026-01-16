//
//  NumberFormat.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/20.
//

import Foundation

extension IntegerFormatStyle {
    public func precision_fraction2() -> Self {
        return precision(.fractionLength(...2))
    }
}

extension FloatingPointFormatStyle {
    public func precision_fraction2() -> Self {
        return precision(.fractionLength(...2))
    }
}
