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

    func minOffset(vertical: Bool) -> CGFloat {
        vertical ? -contentInset.top : -contentInset.left
    }

    func maxOffset(vertical: Bool) -> CGFloat {
        let contentSize = contentSize
        let boundsSize = bounds.size
        let inset = contentInset

        if vertical {
            return contentSize.height - boundsSize.height + inset.bottom
        } else {
            return contentSize.width - boundsSize.width + inset.right
        }
    }

    func progress(vertical: Bool) -> CGFloat {
        let min = minOffset(vertical: vertical)
        let length = maxOffset(vertical: vertical) - min
        if length == 0 {
            return 1.0
        }
        let offset = vertical ? contentOffset.y : contentOffset.x
        return (offset - min) / length
    }

    func offsetAtProgress(_ progress: CGFloat, vertical: Bool) -> CGPoint {
        var point = CGPoint.zero

        let min = minOffset(vertical: vertical)
        let length = maxOffset(vertical: vertical) - min

        if vertical {
            point.y = progress * length + min
        } else {
            point.x = progress * length + min
        }
        return point
    }

    func setContentOffset(_ offset: CGPoint, duration: CGFloat) {
        guard contentOffset != offset else {
            return
        }

        guard duration > 0 else {
            contentOffset = offset
            return
        }

        weak var weakSelf = self
        UIView.animate(withDuration: duration) {
            weakSelf?.contentOffset = offset
        }
    }
}

public extension UIScrollView {
    var topVisiblePoint: CGPoint {
        .init(x: 0, y: minOffset(vertical: true))
    }

    var bottomVisiblePoint: CGPoint {
        .init(x: 0, y: maxOffset(vertical: true))
    }

    func scrollToTop(animated: Bool) {
        setContentOffset(topVisiblePoint, animated: animated)
    }

    func scrollToBottom(animated: Bool) {
        setContentOffset(bottomVisiblePoint, animated: animated)
    }

    var leftVisiblePoint: CGPoint {
        .init(x: minOffset(vertical: false), y: 0)
    }

    var rightVisiblePoint: CGPoint {
        .init(x: maxOffset(vertical: false), y: 0)
    }

    var startVisiblePoint: CGPoint {
        Lang.current.isRTL ? rightVisiblePoint : leftVisiblePoint
    }

    var endVisiblePoint: CGPoint {
        Lang.current.isRTL ? leftVisiblePoint : rightVisiblePoint
    }

    func scrollToLeft(animated: Bool) {
        setContentOffset(leftVisiblePoint, animated: animated)
    }

    func scrollToStart(animated: Bool) {
        setContentOffset(startVisiblePoint, animated: animated)
    }

    func scrollToRight(animated: Bool) {
        setContentOffset(rightVisiblePoint, animated: animated)
    }

    func scrollToEnd(animated: Bool) {
        setContentOffset(endVisiblePoint, animated: animated)
    }
}

public extension UIScrollView {
    @objc func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let size = frame.size
        zoomRect.size = size / scale
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)

        return zoomRect
    }
}
