//
//  UIColorExt.swift
//
//
//  Created by MK on 2021/5/24.
//

import UIKit

public extension UIColor {
    convenience init(rgb: Int64, alpha: CGFloat = 1) {
        var trans: CGFloat = alpha
        if trans < 0 { trans = 0 }
        if trans > 1 { trans = 1 }

        let red = CGFloat((rgb >> 16) & 0xFF) / CGFloat(255.0)
        let green = CGFloat((rgb >> 8) & 0xFF) / CGFloat(255.0)
        let blue = CGFloat(rgb & 0xFF) / CGFloat(255.0)
        self.init(red: red, green: green, blue: blue, alpha: trans)
    }

    convenience init(rgba: Int64) {
        self.init(rgb: rgba >> 8, alpha: CGFloat(rgba & 0xFF) / CGFloat(255.0))
    }

    convenience init(argb: Int64) {
        self.init(rgb: argb, alpha: CGFloat((argb >> 24) & 0xFF) / CGFloat(255.0))
    }

    func lighten(by percentage: CGFloat = 0.2) -> UIColor {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return UIColor(red: min(red + percentage, 1.0),
                       green: min(green + percentage, 1.0),
                       blue: min(blue + percentage, 1.0),
                       alpha: alpha)
    }
}
