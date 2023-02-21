//
//  YXCALayerWrapView.swift
//  MKKit
//
//  Created by MK on 2023/2/21.
//

import UIKit

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
