//
//  ThemeDM.swift
//
//  Created by MK on 2021/5/25.
//

import FluentDarkModeKit
import OpenCombine
import UIKit

public extension AppTheme {
    static func dmColor(light: UIColor, dark: UIColor) -> UIColor {
        UIColor(.dm, light: light, dark: dark)
    }

    static func dmImage(light: UIImage, dark: UIImage) -> UIImage {
        UIImage(.dm, light: light, dark: dark)
    }

    static func dmImage(named name: String) -> UIImage? {
        guard let light = UIImage(named: name),
              let dark = UIImage(named: name + "_d")
        else {
            return nil
        }
        return UIImage(.dm, light: light, dark: dark)
    }

    var dmStyle: DMUserInterfaceStyle {
        switch self {
        case .light:
            return DMUserInterfaceStyle.light
        case .dark:
            return DMUserInterfaceStyle.dark
        case .system:
            return DMUserInterfaceStyle.unspecified
        }
    }
}
