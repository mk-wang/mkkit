//
//  CGRectExt.swift
//  YogaWorkout
//
//  Created by MK on 2021/6/4.
//

import CoreGraphics
import Foundation
import UIKit

// MARK: - Properties

public extension CGRect {
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - size.width / 2.0, y: center.y - size.height / 2.0)
        self.init(origin: origin, size: size)
    }

    init(size: CGSize) {
        self.init(origin: .zero, size: size)
    }

    init(origin: CGPoint) {
        self.init(origin: origin, size: .zero)
    }

    var center: CGPoint {
        CGPoint(x: origin.x + width / 2, y: origin.y + height / 2)
    }

    func to(center: CGPoint) -> Self {
        CGRect(center: center, size: size)
    }

    func scale(_ scale: CGFloat) -> Self {
        var rect = self
        rect.origin = rect.origin.scale(scale)
        rect.size = rect.size.scaleTo(scale: scale)
        return rect
    }
}

public extension CGRect {
    func insetBy(x: CGFloat = 0, y: CGFloat = 0) -> Self {
        insetBy(dx: x, dy: y)
    }

    func insetBy(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> Self {
        inset(by: UIEdgeInsets(top: top, left: left, bottom: bottom, right: right))
    }
}
