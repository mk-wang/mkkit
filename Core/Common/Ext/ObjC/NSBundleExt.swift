//
//  BundleExt.swift
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

    func translate(for key: String) -> String? {
        let text = NSLocalizedString(key, tableName: nil, bundle: self, value: Self.kNotMatch, comment: "")
        return text == Self.kNotMatch ? nil : text
    }

    private static let kNotMatch = "X__D)_OKmdQ@#~"
}
