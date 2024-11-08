//
//  AppThemeFont.swift
//  MKKit
//
//  Created by MK on 2024/2/23.
//

import Foundation

public extension AppTheme {
    private static var fontSizeCache = LangLocal<NSMutableDictionary>(restrictToCurrentLang: false) { _ in
        [:] // Initialize empty dictionary for each language
    }

    static func fontSize(for key: String,
                         configure: ValueBuilder1<CGFloat, Lang>) -> CGFloat
    {
        let lang = Lang.current
        var dict = fontSizeCache.value

        if let value = dict[key] as? CGFloat {
            return value
        }

        let value = configure(lang)
        dict[key] = value
        return value
    }
}
