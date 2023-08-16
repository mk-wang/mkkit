//
//  CGPointExt.swift
//
//
//  Created by MK on 2021/6/4.
//

import CoreGraphics

public extension CGPoint {
    func scale(_ scale: CGFloat) -> Self {
        CGPoint(x: x * scale, y: y * scale)
    }

    func add(_ x: CGFloat = 0, _ y: CGFloat = 0) -> Self {
        CGPoint(x: self.x + x, y: self.y + y)
    }

    func sub(_ x: CGFloat = 0, _ y: CGFloat = 0) -> Self {
        CGPoint(x: self.x - x, y: self.y - y)
    }

    func add(_ offset: CGPoint) -> Self {
        CGPoint(x: x + offset.x, y: y + offset.y)
    }

    func sub(_ offset: CGPoint) -> Self {
        CGPoint(x: x - offset.x, y: y - offset.y)
    }

    func toRect(size: CGSize = .zero) -> CGRect {
        CGRect(origin: self, size: size)
    }
}

public extension CGPoint {
    var center: CGFloat {
        (x + y) / 2
    }

    var size: CGSize {
        CGSize(width: x, height: y)
    }

    var swap: CGPoint {
        CGPoint(x: y, y: x)
    }
}
