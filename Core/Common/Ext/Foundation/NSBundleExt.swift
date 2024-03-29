//
//  NSBundleExt.swift
//
//
//  Created by MK on 2022/4/1.
//

import Foundation

public extension Bundle {
    class var base: Bundle? {
        let main = Self.main
        guard let path = main.path(forResource: "Base", ofType: "lproj"), let bundle = Bundle(path: path) else {
            return nil
        }
        return bundle
    }

    func translate(for key: CustomStringConvertible) -> String? {
        translate(for: key.description)
    }

    func translate(for key: String) -> String? {
        let text = localizedString(forKey: key, value: Self.kNotMatch, table: nil)
        return text == Self.kNotMatch ? nil : text
    }

    private static let kNotMatch = "!@#$%^&*)("
}
