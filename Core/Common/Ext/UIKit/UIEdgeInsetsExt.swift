//
//  UIEdgeInsetsExt.swift
//
//
//  Created by MK on 2022/3/28.
//

import UIKit

public extension UIEdgeInsets {
    static func symmetric(vertical: CGFloat, horizontal: CGFloat) -> Self {
        UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    static func horizontal(_ value: CGFloat) -> Self {
        .init(top: 0, left: value, bottom: 0, right: value)
    }

    static func vertical(_ value: CGFloat) -> Self {
        .init(top: value, left: 0, bottom: value, right: 0)
    }

//    static func only(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
//        UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
//    }

    var verticalSize: CGFloat {
        top + bottom
    }

    var horizontalSize: CGFloat {
        left + right
    }
}

// MARK: - MKEdgeInsets

public struct MKEdgeInsets {
    var top: CGFloat?
    var start: CGFloat?
    var bottom: CGFloat?
    var end: CGFloat?

    public init(top: CGFloat? = nil, start: CGFloat? = nil, bottom: CGFloat? = nil, end: CGFloat? = nil) {
        self.top = top
        self.start = start
        self.bottom = bottom
        self.end = end
    }

    public init(vertical val: CGFloat) {
        top = val
        bottom = val
    }

    public init(horizontal val: CGFloat) {
        start = val
        end = val
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
