//
//  CALayerWrapView.swift
//  MKKit
//
//  Created by MK on 2023/2/21.
//

import UIKit

// MARK: - CALayerWrapView

open class CALayerWrapView: UIView {
    public var wrapLayer: CALayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            if let wrapLayer {
                wrapLayer.frame = bounds
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
        gradientLayer(colors: colors,
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

public extension CALayerWrapView {
    func updateGradient(colors: [UIColor],
                        locations: [CGFloat]? = nil)
    {
        guard let gradientLayer = wrapLayer as? CAGradientLayer else {
            return
        }
        gradientLayer.colors = colors.map(\.cgColor)
        if let locations {
            gradientLayer.locations = locations.map { NSNumber(value: $0) }
        }
    }
}

// MARK: - GradientDirection

public enum GradientDirection {
    case horizontal
    case ltrHorizontal
    case vertical
    case diagonal
    case reverseDiagonal

    public var startPoint: CGPoint {
        switch self {
        case .horizontal:
            Lang.current.isRTL ? CGPoint(x: 1.0, y: 0.5) : CGPoint(x: 0.0, y: 0.5)
        case .ltrHorizontal:
            CGPoint(x: 0.0, y: 0.5)
        case .vertical:
            CGPoint(x: 0.5, y: 0.0)
        case .diagonal:
            CGPoint(x: 0.0, y: 0.0)
        case .reverseDiagonal:
            CGPoint(x: 1.0, y: 0.0)
        }
    }

    public var endPoint: CGPoint {
        switch self {
        case .horizontal:
            Lang.current.isRTL ? CGPoint(x: 0.0, y: 0.5) : CGPoint(x: 1.0, y: 0.5)
        case .ltrHorizontal:
            CGPoint(x: 1.0, y: 0.5)
        case .vertical:
            CGPoint(x: 0.5, y: 1.0)
        case .diagonal:
            CGPoint(x: 1.0, y: 1.0)
        case .reverseDiagonal:
            CGPoint(x: 0.0, y: 1.0)
        }
    }
}

public extension CALayerWrapView {
    class func gradient(direction: GradientDirection,
                        colors: [UIColor],
                        locations: [CGFloat]? = nil)
        -> CALayerWrapView
    {
        gradientLayer(colors: colors,
                      start: direction.startPoint,
                      end: direction.endPoint,
                      locations: locations)
    }
}

public extension UIView {
    // MARK: - Apply Text Gradient

    /// Apply gradient color
    /// - Parameters:
    ///   - colors: Array of UIColors for the gradient
    ///   - direction: Direction of the gradient
    ///   - locations: Optional locations for the colors (0.0 to 1.0)
    func addGradient(direction: GradientDirection = .horizontal,
                     colors: [UIColor],
                     locations: [CGFloat]? = nil)
    {
        // Create gradient layer
        let gradientLayer = CALayerWrapView.gradient(
            direction: direction,
            colors: colors,
            locations: locations
        )

        gradientLayer.addSnpEdgesToSuper()

        // Create mask
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }

        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if let image {
            let maskLayer = CALayer()
            maskLayer.frame = bounds
            maskLayer.contents = image.cgImage
            gradientLayer.layer.mask = maskLayer

            // Add gradient
            insertSnpSubview(gradientLayer, at: 0)
        }
    }
}
