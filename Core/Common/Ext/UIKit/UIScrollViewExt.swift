//
//  UIScrollViewExt.swift
//
//
//  Created by MK on 2021/9/16.
//

import Foundation
import UIKit

public extension UIScrollView {
    var visibleRect: CGRect { CGRect(origin: contentOffset, size: bounds.size) }

    func checkVisibleWidth(view: UIView) -> CGFloat {
        let rect = view.convert(view.bounds, to: self)
        let scrollWidth = bounds.width
        let x = contentOffset.x
        var start = rect.minX - x
        if start < 0 {
            start = 0
        }
        if start > scrollWidth {
            return 0
        }
        var end = rect.maxX - x
        if end > scrollWidth {
            end = scrollWidth
        }
        return end - start
    }

    func checkVisibleHeight(view: UIView) -> CGFloat {
        let rect = view.convert(view.bounds, to: self)
        let scrollHeight = bounds.height
        let y = contentOffset.y
        var start = rect.minY - y
        if start < 0 {
            start = 0
        }
        if start > scrollHeight {
            return 0
        }
        var end = rect.maxY - y
        if end > scrollHeight {
            end = scrollHeight
        }
        return end - start
    }

    func minOffset(for vertical: Bool) -> CGFloat {
        vertical ? -contentInset.top : -contentInset.left
    }

    func maxOffset(for vertical: Bool) -> CGFloat {
        let contentSize = contentSize
        let boundsSize = bounds.size
        let inset = contentInset

        if vertical {
            return contentSize.height - boundsSize.height + inset.bottom
        } else {
            return contentSize.width - boundsSize.width + inset.right
        }
    }

    func progress(for vertical: Bool) -> CGFloat {
        let min = minOffset(for: vertical)
        let length = maxOffset(for: vertical) - min
        if length == 0 {
            return 1.0
        }
        let offset = vertical ? contentOffset.y : contentOffset.x
        return (offset - min) / length
    }

    func offsetAtProgress(_ progress: CGFloat, vertical: Bool) -> CGPoint {
        var point = CGPoint.zero

        let min = minOffset(for: vertical)
        let length = maxOffset(for: vertical) - min

        if vertical {
            point.y = progress * length + min
        } else {
            point.x = progress * length + min
        }
        return point
    }
}

public extension UIScrollView {
    @objc func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let size = frame.size
        zoomRect.size = size.scaleTo(scale: 1 / scale)
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)

        return zoomRect
    }
}
