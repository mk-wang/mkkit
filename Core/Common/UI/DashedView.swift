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
        var dashFillColor: UIColor?
        var dashLength: CGFloat = 0
        var betweenDashesSpace: CGFloat = 0
        var cornerRadius: CGFloat = 0

        public init(dashWidth: CGFloat,
                    dashColor: UIColor,
                    dashFillColor: UIColor? = nil,
                    dashLength: CGFloat,
                    betweenDashesSpace: CGFloat,
                    cornerRadius: CGFloat)
        {
            self.dashWidth = dashWidth
            self.dashColor = dashColor
            self.dashFillColor = dashFillColor
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
        dashBorder.fillColor = config.dashFillColor?.cgColor

        let rect = bounds.insetBy(dx: config.dashWidth / 2, dy: config.dashWidth / 2)
        if config.cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: rect, cornerRadius: config.cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: rect).cgPath
        }

        layer.addSublayer(dashBorder)

        self.dashBorder = dashBorder
    }
}
