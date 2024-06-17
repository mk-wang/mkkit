//
//  UICollectionViewFlowLayoutExt.swift
//  MKKit
//
//  Created by MK on 2024/6/16.
//

import UIKit

// MARK: - VerticalOrHorizontal

public protocol VerticalOrHorizontal {
    var isVertical: Bool {
        get
    }
}

public extension VerticalOrHorizontal {
    func pointValue(_ point: CGPoint) -> CGFloat {
        isVertical ? point.y : point.x
    }

    func pointCrossValue(_ point: CGPoint) -> CGFloat {
        isVertical ? point.x : point.y
    }

    func sizeValue(_ size: CGSize) -> CGFloat {
        isVertical ? size.height : size.width
    }

    func sizeCrossValue(_ size: CGSize) -> CGFloat {
        isVertical ? size.width : size.height
    }

    func makePoint(value: CGFloat, cross: CGFloat) -> CGPoint {
        isVertical ? .init(x: cross, y: value) : .init(x: value, y: cross)
    }

    func makeSize(value: CGFloat, cross: CGFloat) -> CGSize {
        isVertical ? .init(width: cross, height: value) : .init(width: value, height: cross)
    }
}

// MARK: - UICollectionViewFlowLayout + VerticalOrHorizontal

extension UICollectionViewFlowLayout: VerticalOrHorizontal {
    public var isVertical: Bool {
        scrollDirection == .vertical
    }
}
