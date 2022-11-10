//
//  UITextFieldExt.swift
//
//
//  Created by MK on 2022/7/12.
//

import UIKit

public extension UITextField {
    func setupPlaceholder(text: String, color: UIColor) {
        placeholder = text
        attributedPlaceholder = NSAttributedString(string: text,
                                                   attributes: [NSAttributedString.Key.foregroundColor: color])
    }
}
