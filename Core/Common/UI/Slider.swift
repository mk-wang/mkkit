//
//  YXSlider.swift
//  MKKit
//
//  Created by MK on 2023/8/9.
//

import UIKit

open class Slider: UISlider {
    open var slideThumbSpace: CGFloat = 0

    override open func thumbRect(forBounds bounds: CGRect, trackRect: CGRect, value: Float) -> CGRect {
        var diff = CGFloat(value - 0.5) * 2 * slideThumbSpace
        let rtl = Lang.current.isRTL
        let left = (rtl && diff > 0) || (!rtl && diff < 0)
        diff = abs(diff)
        if left {
            diff = -diff
        }

        var rect = trackRect
        rect.origin.x = rect.minX + diff

        return super.thumbRect(forBounds: bounds,
                               trackRect: rect,
                               value: value)
    }
}
