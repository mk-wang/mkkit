//
//  CGPointExt.swift
//
//
//  Created by MK on 2021/6/4.
//

import CoreGraphics

public extension CGPoint {
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }

    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        CGPoint(x: left.x / right, y: left.y / right)
    }

    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        CGPoint(x: left.x * right, y: left.y * right)
    }

    static func /= (left: inout CGPoint, right: CGFloat) {
        left = left / right
    }

    static func *= (left: inout CGPoint, right: CGFloat) {
        left = left * right
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

    func toRect(size: CGSize = .zero) -> CGRect {
        CGRect(origin: self, size: size)
    }
}

public extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        let d1 = self.x - other.x
        let d2 = self.y - other.y
        return sqrt(d1 * d1 + d2 * d2)
    }
}
