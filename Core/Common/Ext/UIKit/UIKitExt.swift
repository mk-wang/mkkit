//
//  UIKitExt.swift
//  MKKit
//
//  Created by MK on 2023/7/17.
//

import UIKit

public extension UIStatusBarStyle {
    static var darkOrDefault: Self {
        if #available(iOS 13.0, *) {
            .darkContent
        } else {
            .default
        }
    }
}
