//
//  DateFormat.swift
//  UIPaaS
//
//  Created by wuwei on 2025/6/20.
//

import Foundation

extension Date.ISO8601FormatStyle {
    public static let date: Self = .init(dateSeparator: .dash, dateTimeSeparator: .space, timeZone: .current).year().month().day()
    public static let time: Self = .init().time(includingFractionalSeconds: false)
    public static let dateTime: Self = .init(dateSeparator: .dash, dateTimeSeparator: .space, timeZone: .current).year().month().day().time(includingFractionalSeconds: false)
}

extension Date {
    public func formatted_date() -> String {
        return formatted(Date.ISO8601FormatStyle.date)
    }
    
    public func formatted_time() -> String {
        return formatted(Date.ISO8601FormatStyle.time)
    }
    
    public func formatted_dateTime() -> String {
        return formatted(Date.ISO8601FormatStyle.dateTime)
    }
}
