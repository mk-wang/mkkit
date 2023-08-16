//
//  UIEdgeInsetsExt.swift
//
//
//  Created by MK on 2022/3/28.
//

import UIKit

public extension UIEdgeInsets {
    static func vertical(_ size: CGFloat) -> Self {
        symmetric(vertical: size)
    }

    static func horizontal(_ size: CGFloat) -> Self {
        symmetric(horizontal: size)
    }

    static func symmetric(vertical: CGFloat = 0, horizontal: CGFloat = 0) -> Self {
        UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    static func only(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
        UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    var verticalSize: CGFloat {
        top + bottom
    }

    var horizontalSize: CGFloat {
        left + right
    }
}
