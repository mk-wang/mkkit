//
//  UIEdgeInsetsExt.swift
//
//
//  Created by MK on 2022/3/28.
//

import UIKit

public extension UIEdgeInsets {
    static func symmetric(vertical: CGFloat, horizontal: CGFloat) -> Self {
        UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    static func horizontal(_ value: CGFloat = 0) -> Self {
        .init(top: 0, left: value, bottom: 0, right: value)
    }

    static func vertical(_ value: CGFloat = 0) -> Self {
        .init(top: value, left: 0, bottom: value, right: 0)
    }

//    static func only(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
//        UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
//    }

    var verticalSize: CGFloat {
        top + bottom
    }

    var horizontalSize: CGFloat {
        left + right
    }
}
