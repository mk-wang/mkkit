//
//  AppThemeFont.swift
//  MKKit
//
//  Created by MK on 2024/2/23.
//

import Foundation

public extension AppTheme {
    private static var fonts = [Lang: [String: CGFloat]]()

    static func fontSize(for key: String,
                         configure: ValueBuilder1<CGFloat, Lang>) -> CGFloat
    {
        let lang = Lang.current
        var dict = fonts[lang]
        if let value = dict?[key] {
            return value
        }

        let value = configure(lang)
        if dict == nil {
            fonts[lang] = [key: value]
        } else {
            fonts[lang]?[key] = value
        }
        return value
    }
}
