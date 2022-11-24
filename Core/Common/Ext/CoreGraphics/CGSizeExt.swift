//
//  CGSizeExt.swift
//  YogaWorkout
//
//  Created by MK on 2021/6/4.
//

import CoreGraphics

public extension CGSize {
    func scaleTo(scale: CGFloat) -> Self {
        CGSize(width: width * scale, height: height * scale)
    }

    func scaleTo(width: CGFloat) -> Self {
        CGSize(width: width, height: height * (width / self.width))
    }

    func scaleTo(height: CGFloat) -> Self {
        CGSize(width: width * (height / self.height), height: height)
    }

    func add(width: CGFloat = 0, height: CGFloat = 0) -> Self {
        CGSize(width: self.width + width, height: self.height + height)
    }

    func toRect(point: CGPoint = .zero) -> CGRect {
        CGRect(origin: point, size: self)
    }

    var swap: Self {
        CGSize(height, width)
    }
}

public extension CGSize {
    static func + (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width + right.width, height: left.height + right.height)
    }

    static func - (left: CGSize, right: CGSize) -> CGSize {
        CGSize(width: left.width - right.width, height: left.height - right.height)
    }

    static func += (left: inout CGSize, right: CGSize) {
        left = left + right
    }

    static func -= (left: inout CGSize, right: CGSize) {
        left = left - right
    }

    static func / (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width / right, height: left.height / right)
    }

    static func * (left: CGSize, right: CGFloat) -> CGSize {
        CGSize(width: left.width * right, height: left.height * right)
    }

    static func /= (left: inout CGSize, right: CGFloat) {
        left = left / right
    }

    static func *= (left: inout CGSize, right: CGFloat) {
        left = left * right
    }
}

public extension CGSize {
    static func square(_ size: CGFloat) -> Self {
        CGSize(width: size, height: size)
    }
}

public extension CGSize {
    var point: CGPoint {
        CGPoint(x: width, y: height)
    }
}
