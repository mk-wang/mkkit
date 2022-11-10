//
//  Fix.swift
//  YogaWorkout
//
//  Created by MK on 2021/5/28.
//

import Foundation
import YogaKit

extension UIView {
    func fixYGLayout() {
        subviews.forEach {
            let yoga = $0.yoga
            if !yoga.isEnabled {
                yoga.isIncludedInLayout = false
            }
        }
    }

    func applyYGLayout(preservingOrigin: Bool) {
        applyYGLayout(preservingOrigin: preservingOrigin,
                      rtl: Lang.current.isRTL)
    }

    func applyYGLayout(preservingOrigin: Bool, rtl: Bool) {
        yoga.direction = rtl ? .RTL : .LTR
        yoga.applyLayout(preservingOrigin: preservingOrigin)
    }

    func applyYGLayout(preservingOrigin: Bool, dimensionFlexibility: YGDimensionFlexibility) {
        applyYGLayout(preservingOrigin: preservingOrigin,
                      dimensionFlexibility: dimensionFlexibility,
                      rtl: Lang.current.isRTL)
    }

    func applyYGLayout(preservingOrigin: Bool, dimensionFlexibility: YGDimensionFlexibility, rtl: Bool) {
        yoga.direction = rtl ? .RTL : .LTR
        yoga.applyLayout(preservingOrigin: preservingOrigin,
                         dimensionFlexibility: dimensionFlexibility)
    }

    func applyYG(padding: UIEdgeInsets) {
        configureLayout { layout in
            layout.isEnabled = true
            layout.paddingTop = padding.top.yg
            layout.paddingBottom = padding.bottom.yg
            layout.paddingStart = padding.left.yg
            layout.paddingEnd = padding.right.yg
        }
    }

    func applyYG(margin: UIEdgeInsets) {
        configureLayout { layout in
            layout.isEnabled = true
            layout.marginTop = margin.top.yg
            layout.marginBottom = margin.bottom.yg
            layout.marginStart = margin.left.yg
            layout.marginEnd = margin.right.yg
        }
    }

    func ygMarkDirty() {
        if isYogaEnabled {
            yoga.markDirty()
        }
    }

    func ygReset() {
        yoga.ygReset()
    }

    func ygIsolate() {
        yoga.ygIsolate()
    }

    func ygResetSubviews() {
        subviews.forEach {
            $0.ygResetSubviews()
        }
        ygReset()
    }

    func ygDisable() {
        yoga.isEnabled = false
        yoga.isIncludedInLayout = false
    }
}

extension UIView {
    func applySafeAreaInsets() {
        applyYG(padding: safeAreaInsets)
    }
}

extension YGLayout {
    var size: CGSize {
        set {
            width = newValue.width.yg
            height = newValue.height.yg
        }
        get {
            CGSize.zero
        }
    }

    var square: CGFloat {
        set {
            width = newValue.yg
            height = newValue.yg
        }
        get {
            0
        }
    }
}

public extension FloatingPoint {
    var yg: YGValue {
        YGValue(cgFloat)
    }
}

extension UIScrollView {
    func ygLayoutVertical(by width: CGFloat? = nil,
                          configure: (UIView) -> Void)
    {
        let view = UIView()

        let width = width ?? bounds.width

        view.configureLayout { layout in
            layout.isEnabled = true
            layout.width = width.yg
        }

        configure(view)

        view.applyYGLayout(preservingOrigin: false,
                           dimensionFlexibility: .flexibleHeight)
        addSubview(view)
        view.ygDisable()

        contentSize = view.bounds.size
        fixYGLayout()
    }

    func ygLayoutHorizontal(by height: CGFloat? = nil,
                            toFirst: Bool = true,
                            configure: (UIView) -> Void)
    {
        let view = UIView()
        let height = height ?? bounds.height
        view.configureLayout { layout in
            layout.isEnabled = true
            layout.height = height.yg
            layout.flexDirection = .row
        }

        configure(view)

        view.applyYGLayout(preservingOrigin: false, dimensionFlexibility: .flexibleWidth)
        addSubview(view)
        view.ygDisable()

        var rect = view.bounds
        contentSize = rect.size

        if toFirst, Lang.current.isRTL, rect.size.width > 1 {
            rect.origin.x = rect.size.width - 1
            rect.size.width = 1
            scrollRectToVisible(rect, animated: false)
        }
        fixYGLayout()
    }
}
