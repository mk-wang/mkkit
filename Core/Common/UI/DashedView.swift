//
//  DashedView.swift
//  MKKit
//
//  Created by MK on 2024/1/9.
//

import UIKit

// MARK: - CustomDashedView

open class DashedView: UIView {
    public struct Config {
        var dashWidth: CGFloat = 0
        var dashColor: UIColor = .clear
        var dashLength: CGFloat = 0
        var betweenDashesSpace: CGFloat = 0
        var cornerRadius: CGFloat = 0

        public init(dashWidth: CGFloat,
                    dashColor: UIColor,
                    dashLength: CGFloat,
                    betweenDashesSpace: CGFloat,
                    cornerRadius: CGFloat)
        {
            self.dashWidth = dashWidth
            self.dashColor = dashColor
            self.dashLength = dashLength
            self.betweenDashesSpace = betweenDashesSpace
            self.cornerRadius = cornerRadius
        }
    }

    public var config: Config? {
        didSet {
            if dashBorder != nil {
                setNeedsLayout()
            }
        }
    }

    private weak var dashBorder: CAShapeLayer?

    public func updateDashColor(color: UIColor) {
        dashBorder?.strokeColor = color.cgColor

        config?.dashColor = color
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        dashBorder?.removeFromSuperlayer()

        guard let config else {
            return
        }

        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = config.dashWidth
        dashBorder.strokeColor = config.dashColor.cgColor
        dashBorder.lineDashPattern = [config.dashLength, config.betweenDashesSpace] as [NSNumber]
        dashBorder.lineJoin = .round
        dashBorder.frame = bounds
        dashBorder.fillColor = nil

        if config.cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: config.cornerRadius).cgPath
//            layer.masksToBounds = true
//            layer.cornerRadius = config.cornerRadius
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
//            layer.masksToBounds = false
//            layer.cornerRadius = 0
        }

        layer.addSublayer(dashBorder)

        self.dashBorder = dashBorder
    }
}
