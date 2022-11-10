//
//  UIFontExt.swift
//
//
//  Created by MK on 2022/3/24.
//

import UIKit

public extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        guard let descriptor = fontDescriptor.withSymbolicTraits(traits) else {
            return nil
        }
        return UIFont(descriptor: descriptor, size: 0) // size 0 means keep the size as it is
    }

    var bold: UIFont? {
        withTraits(traits: .traitBold)
    }

    var italic: UIFont? {
        withTraits(traits: .traitItalic)
    }
}
