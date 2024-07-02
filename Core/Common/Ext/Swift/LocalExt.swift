//
//  LocalExt.swift
//  MKKit
//
//  Created by MK on 2023/7/25.
//

import Foundation

extension Locale {
    var is12Hour: Bool {
        let fmt = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: self)
        let rt = fmt?.contains("a") ?? false
        return rt
    }

    // am / pm
    var amPmStrings: [String] {
        let fmt = DateFormatter()
        fmt.dateFormat = "a"
        let date: Date = .init()
        let next = date.addingTimeInterval(Date.oneHourInterval * 12)
        var list = [fmt.string(from: date), fmt.string(from: next)]
        return list
    }
}
