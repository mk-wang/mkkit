//
//  DashedView.swift
//  MKKit
//
//  Created by MK on 2024/1/9.
//

import UIKit

// MARK: - DashedView

open class DashedView: UIView {
    // MARK: - Constants

    public static let DEFAULT_DASH_WIDTH: CGFloat = 1.0
    public static let DEFAULT_DASH_LENGTH: CGFloat = 1.0
    public static let DEFAULT_DASH_SPACE: CGFloat = 1.0
    public static let MIN_DASH_WIDTH: CGFloat = 0.5
    public static let MIN_DASH_LENGTH: CGFloat = 1.0
    public static let MIN_DASH_SPACE: CGFloat = 1.0

    // MARK: - Config

    public struct Config {
        var dashWidth: CGFloat
        var dashColor: UIColor
        var dashFillColor: UIColor?
        var dashLength: CGFloat
        var dashSpace: CGFloat
        var horizontal: Bool

        public init(dashWidth: CGFloat = DashedView.DEFAULT_DASH_WIDTH,
                    dashColor: UIColor = .black,
                    dashFillColor: UIColor? = nil,
                    dashLength: CGFloat = DashedView.DEFAULT_DASH_LENGTH,
                    dashSpace: CGFloat = DashedView.DEFAULT_DASH_SPACE,
                    horizontal: Bool = true)
        {
            // Validate and set parameters with minimum values
            self.dashWidth = max(dashWidth, DashedView.MIN_DASH_WIDTH)
            self.dashColor = dashColor
            self.dashFillColor = dashFillColor
            self.dashLength = max(dashLength, DashedView.MIN_DASH_LENGTH)
            self.dashSpace = max(dashSpace, DashedView.MIN_DASH_SPACE)
            self.horizontal = horizontal
        }
    }

    // MARK: - Properties

    public var config: Config? {
        didSet {
            if oldValue != nil {
                setNeedsLayout()
            }
        }
    }

    private var dashBorder: CAShapeLayer?

    private var lastFrame: CGRect? = nil

    // MARK: - Public Methods

    public func updateDashColor(color: UIColor) {
        guard let dashBorder else { return }

        dashBorder.strokeColor = color.cgColor
        config?.dashColor = color
    }

    // MARK: - Layout

    override open func layoutSubviews() {
        super.layoutSubviews()

        let currentFrame = bounds
        // Validate bounds
        guard let config,
              currentFrame.width > 0,
              currentFrame.height > 0,
              dashBorder?.superlayer == nil || lastFrame != currentFrame
        else {
            return
        }

        lastFrame = currentFrame
        // Remove existing dash border
        dashBorder?.removeFromSuperlayer()

        // Create new dash border
        let newDashBorder = CAShapeLayer()
        setupDashLine(newDashBorder, with: config)

        layer.addSublayer(newDashBorder)
        dashBorder = newDashBorder
    }

    // MARK: - Private Methods

    private func setupDashLine(_ shapeLayer: CAShapeLayer, with config: Config) {
        shapeLayer.lineWidth = config.dashWidth
        shapeLayer.strokeColor = config.dashColor.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineDashPattern = [NSNumber(value: config.dashLength),
                                      NSNumber(value: config.dashSpace)]
        shapeLayer.lineJoin = .round
        shapeLayer.lineCap = .round
        shapeLayer.frame = bounds

        // Create path for centered line
        let path = createCenteredLinePath(config: config)
        shapeLayer.path = path.cgPath
    }

    private func createCenteredLinePath(config: Config) -> UIBezierPath {
        let path = UIBezierPath()
        let inset = config.dashWidth / 2

        if config.horizontal {
            // Horizontal centered line
            let centerY = bounds.midY
            let startX = bounds.minX + inset
            let endX = bounds.maxX - inset

            path.move(to: CGPoint(x: startX, y: centerY))
            path.addLine(to: CGPoint(x: endX, y: centerY))
        } else {
            // Vertical centered line
            let centerX = bounds.midX
            let startY = bounds.minY + inset
            let endY = bounds.maxY - inset

            path.move(to: CGPoint(x: centerX, y: startY))
            path.addLine(to: CGPoint(x: centerX, y: endY))
        }

        return path
    }
}
