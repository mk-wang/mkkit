//
//  YXCALayerWrapView.swift
//  MKKit
//
//  Created by MK on 2023/2/21.
//

import UIKit

// MARK: - YXCALayerWrapView

open class CALayerWrapView: UIView {
    public var wrapLayer: CALayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            if let wrapLayer {
                wrapLayer.frame = self.bounds
                layer.addSublayer(wrapLayer)
            }
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        wrapLayer?.frame = bounds
    }
}

public extension CALayerWrapView {
    class func gradientLayer(colors: [UIColor],
                             start: CGPoint,
                             end: CGPoint,
                             locations: [CGFloat]? = nil)
        -> CALayerWrapView
    {
        let box = CALayerWrapView()
        let bgLayer = CAGradientLayer()
        bgLayer.colors = colors.map(\.cgColor)
        bgLayer.startPoint = start
        bgLayer.endPoint = end
        if let locations {
            bgLayer.locations = locations.map { NSNumber(value: $0) }
        }
        box.wrapLayer = bgLayer
        return box
    }

    class func verticalGradientLayer(colors: [UIColor],
                                     locations: [CGFloat]? = nil)
        -> CALayerWrapView
    {
        Self.gradientLayer(colors: colors,
                           start: .init(0.5, 0),
                           end: .init(0.5, 1),
                           locations: locations)
    }

    class func horizontalGradientLayer(colors: [UIColor],
                                       locations: [CGFloat]? = nil,
                                       directional: Bool = true)
        -> CALayerWrapView
    {
        var start: CGPoint = .init(0, 0.5)
        var end: CGPoint = .init(1, 0.5)
        if directional, Lang.current.isRTL {
            start.x = 1
            end.x = 0
        }
        return Self.gradientLayer(colors: colors,
                                  start: start,
                                  end: end,
                                  locations: locations)
    }
}
