//
//  UITextFieldExt.swift
//
//
//  Created by MK on 2022/7/12.
//

import UIKit

public extension UITextField {
    func setupPlaceholder(text: String,
                          color: UIColor? = nil,
                          font: UIFont? = nil,
                          lineBreakMode: NSLineBreakMode? = nil)
    {
        placeholder = text

        var attrs = [NSAttributedString.Key: Any]()
        if let color {
            attrs[.foregroundColor] = color
        }
        if let font {
            attrs[.font] = font
        }

        if let lineBreakMode {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = lineBreakMode
            attrs[.paragraphStyle] = paragraphStyle
        }

        if !attrs.isEmpty {
            attributedPlaceholder = NSAttributedString(string: text, attributes: attrs)
        }
    }
}
