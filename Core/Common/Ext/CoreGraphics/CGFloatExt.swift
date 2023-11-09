//
//  CGFloatExt.swift
//
//
//  Created by MK on 2021/6/4.
//

import CoreGraphics
import Foundation

public extension CGFloat {
    var size: CGSize {
        CGSize(width: self, height: self)
    }
}
