//
//  CharacterSetExt.swift
//  MKKit
//
//  Created by MK on 2024/7/2.
//

import Foundation

public extension CharacterSet {
    static let englishAlphanumerics: CharacterSet = {
        var set = CharacterSet()
        set.insert(charactersIn: "0" ... "9")
        set.insert(charactersIn: "A" ... "Z")
        set.insert(charactersIn: "a" ... "z")
        return set
    }()
}
