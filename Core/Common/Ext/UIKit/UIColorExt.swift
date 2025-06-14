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

    convenience init?(argb hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        let strCount = cString.count
        var colorValue: Int64 = 0
        guard strCount == 6 || strCount == 8, Scanner(string: cString).scanHexInt64(&colorValue) else {
            return nil
        }

        var alpha: CGFloat = 1.0
        if strCount == 8 {
            self.init(argb: colorValue)
        } else {
            self.init(rgb: colorValue, alpha: 1)
        }
    }

    convenience init?(rgb hex: String) {
        self.init(argb: hex)
    }

    convenience init?(rgba hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        let strCount = cString.count
        var colorValue: Int64 = 0
        guard strCount == 6 || strCount == 8, Scanner(string: cString).scanHexInt64(&colorValue) else {
            return nil
        }

        if strCount == 8 {
            self.init(rgba: colorValue)
        } else {
            self.init(rgb: colorValue, alpha: 1)
        }
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

public extension Int64 {
    var argb: UIColor {
        .init(argb: self)
    }

    var rgba: UIColor {
        .init(rgba: self)
    }

    var rgb: UIColor {
        .init(rgb: self)
    }
}

public extension UInt64 {
    var argb: UIColor {
        .init(argb: Int64(self))
    }

    var rgba: UIColor {
        .init(rgba: Int64(self))
    }

    var rgb: UIColor {
        .init(rgb: Int64(self))
    }
}

public extension Int {
    var argb: UIColor {
        .init(argb: Int64(self))
    }

    var rgba: UIColor {
        .init(rgba: Int64(self))
    }

    var rgb: UIColor {
        .init(rgb: Int64(self))
    }

    func rgbAlpha(_ alpha: CGFloat) -> UIColor {
        rgb.withAlphaComponent(alpha)
    }
}

public extension UInt {
    var argb: UIColor {
        .init(argb: Int64(self))
    }

    var rgba: UIColor {
        .init(rgba: Int64(self))
    }

    var rgb: UIColor {
        .init(rgb: Int64(self))
    }
}
