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
    var amPmString: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "a"
        return fmt.string(from: .init())
    }
}
