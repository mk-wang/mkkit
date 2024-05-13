//
//  CGSizeExt.swift
//
//
//  Created by MK on 2021/6/4.
//

import CoreGraphics

public extension CGSize {
    var isEmpty: Bool {
        width == 0 || height == 0
    }

    var isNotEmpty: Bool {
        !isEmpty
    }

    var area: CGFloat { width * height }

    func scale(width: CGFloat) -> Self {
        CGSize(width: width, height: height * (width / self.width))
    }

    func scale(height: CGFloat) -> Self {
        CGSize(width: width * (height / self.height), height: height)
    }

    func scale(fit: CGSize) -> Self {
        let scale = min(fit.width / width, fit.height / height)
        return self * scale
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

    var center: CGPoint {
        CGPoint(x: width * 0.5, y: height * 0.5)
    }
}
