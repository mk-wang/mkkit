//
//  LangDate.swift
//
//
//  Created by MK on 2022/5/10.
//

import Foundation

extension Lang {
    static var locale: Locale {
        let current = Lang.current
        let identifier = current.rawValue
        return Locale(identifier: identifier)
    }

    static func dateFormat(fromTemplate: String) -> DateFormatter {
        let locale = Lang.locale
        let stringFmt = DateFormatter.dateFormat(fromTemplate: fromTemplate, options: 0, locale: locale)
        let dateFmt = DateFormatter()
        dateFmt.locale = locale
        dateFmt.dateFormat = stringFmt
        return dateFmt
    }
}
