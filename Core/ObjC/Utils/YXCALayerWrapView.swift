//
//  YXCALayerWrapView.swift
//  MKKit
//
//  Created by MK on 2023/2/21.
//

import UIKit

// MARK: - YXCALayerWrapView

open class YXCALayerWrapView: UIView {
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

public extension YXCALayerWrapView {
    class func gradientLayerWrap(colors: [UIColor],
                                 start: CGPoint,
                                 end: CGPoint,
                                 locations: [CGFloat]? = nil)
        -> YXCALayerWrapView
    {
        let box = YXCALayerWrapView()
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
        -> YXCALayerWrapView
    {
        Self.gradientLayerWrap(colors: colors,
                               start: .init(0.5, 0),
                               end: .init(0.5, 1),
                               locations: locations)
    }
}
