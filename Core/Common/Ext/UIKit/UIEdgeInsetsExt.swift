//
//  UIEdgeInsetsExt.swift
//
//
//  Created by MK on 2022/3/28.
//

import UIKit

public extension UIEdgeInsets {
    static func symmetric(vertical: CGFloat, horizontal: CGFloat) -> Self {
        .init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    static func all(_ value: CGFloat) -> Self {
        .init(top: value, left: value, bottom: value, right: value)
    }

    static func horizontal(_ value: CGFloat, top: CGFloat = 0, bottom: CGFloat = 0) -> Self {
        .init(top: top, left: value, bottom: bottom, right: value)
    }

    static func vertical(_ value: CGFloat, left: CGFloat = 0, right: CGFloat = 0) -> Self {
        .init(top: value, left: left, bottom: value, right: right)
    }

    var verticalSize: CGFloat {
        top + bottom
    }

    var horizontalSize: CGFloat {
        left + right
    }
}

public extension UIEdgeInsets {
    static func + (left: UIEdgeInsets, right: UIEdgeInsets) -> UIEdgeInsets {
        .init(top: left.top + right.top,
              left: left.left + right.left,
              bottom: left.bottom + right.bottom,
              right: left.right + right.right)
    }

    static func max(_ left: UIEdgeInsets, _ right: UIEdgeInsets) -> UIEdgeInsets {
        .init(top: CGFloat.maximum(left.top, right.top),
              left: CGFloat.maximum(left.left, right.left),
              bottom: CGFloat.maximum(left.bottom, right.bottom),
              right: CGFloat.maximum(left.right, right.right))
    }
}

// MARK: - MKEdgeInsets

public struct MKEdgeInsets {
    public let top: CGFloat?
    public let start: CGFloat?
    public let bottom: CGFloat?
    public let end: CGFloat?

    public init(top: CGFloat? = nil, start: CGFloat? = nil, bottom: CGFloat? = nil, end: CGFloat? = nil) {
        self.top = top
        self.start = start
        self.bottom = bottom
        self.end = end
    }

    public init(vertical val: CGFloat, start: CGFloat? = nil, end: CGFloat? = nil) {
        top = val
        bottom = val
        self.start = start
        self.end = end
    }

    public init(horizontal val: CGFloat, top: CGFloat? = nil, bottom: CGFloat? = nil) {
        start = val
        end = val
        self.top = top
        self.bottom = bottom
    }

    static func only(top: CGFloat? = nil, start: CGFloat? = nil, bottom: CGFloat? = nil, end: CGFloat? = nil) -> Self {
        .init(top: top, start: start, bottom: bottom, end: end)
    }

    static func vertical(_ val: CGFloat, start: CGFloat? = nil, end: CGFloat? = nil) -> Self {
        .init(vertical: val, start: start, end: end)
    }

    static func horizontal(_ val: CGFloat, top: CGFloat? = nil, bottom: CGFloat? = nil) -> Self {
        .init(horizontal: val, top: top, bottom: bottom)
    }

    static func symmetric(vertical: CGFloat, horizontal: CGFloat) -> Self {
        .init(top: vertical, start: horizontal, bottom: vertical, end: horizontal)
    }
}

// MARK: Codable

extension MKEdgeInsets: Codable {}

public extension MKEdgeInsets {
    private static func unionFloat(_ lhs: CGFloat?, _ rhs: CGFloat?) -> CGFloat? {
        guard let lhs, let rhs else {
            return lhs != nil ? lhs : rhs
        }
        return max(lhs, rhs)
    }

    static func union(_ lhs: Self, _ rhs: Self) -> Self {
        .init(top: unionFloat(lhs.top, rhs.top),
              start: unionFloat(lhs.start, rhs.start),
              bottom: unionFloat(lhs.bottom, rhs.bottom),
              end: unionFloat(lhs.end, rhs.end))
    }
}

// MARK: Codable

public extension MKEdgeInsets {
    var uiInsets: UIEdgeInsets {
        .only(top: top ?? 0, start: start ?? 0, bottom: bottom ?? 0, end: end ?? 0)
    }
}

public extension UIEdgeInsets {
    var mkInsets: MKEdgeInsets {
        .init(top: top == 0 ? nil : top, start: start == 0 ? nil : start, bottom: bottom == 0 ? nil : bottom, end: end == 0 ? nil : end)
    }
}
