//
//  Lerpable.swift
//
//
//  Created by MK on 2022/4/23.
//

import Foundation

// MARK: - Lerpable

protocol Lerpable {
    func lerp(with: Self, by: CGFloat) -> Self
}

// MARK: - CGFloat + Lerpable

extension CGFloat: Lerpable {
    func lerp(with other: Self, by k: CGFloat) -> Self {
        self * (1.0 - k) + other * k
    }
}

// MARK: - CGPoint + Lerpable

extension CGPoint: Lerpable {
    func lerp(with other: CGPoint, by k: CGFloat) -> CGPoint {
        CGPoint(
            x: x.lerp(with: other.x, by: k),
            y: y.lerp(with: other.y, by: k)
        )
    }
}

// MARK: - CGRect + Lerpable

extension CGRect: Lerpable {
    internal func lerp(with other: CGRect, by k: CGFloat) -> CGRect {
        CGRect(
            x: origin.x.lerp(with: other.origin.x, by: k),
            y: origin.y.lerp(with: other.origin.y, by: k),
            width: width.lerp(with: other.width, by: k),
            height: height.lerp(with: other.height, by: k)
        )
    }
}

func lerpKeyframes<T: Lerpable>(_ k: CGFloat, array: [T]) -> T? {
    let leftBound = Int(k)
    guard leftBound >= 0 else { return array.first }
    guard leftBound < array.count else { return array.last }

    let fraction = fmod(k, 1.0)

    return array[leftBound].lerp(with: array[leftBound + 1], by: fraction)
}
