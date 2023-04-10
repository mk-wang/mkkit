//
//  UIImageExt.swift
//
//
//  Created by MK on 2021/7/22.
//

import UIKit

public extension UIImage {
    var original: UIImage {
        withRenderingMode(.alwaysOriginal)
    }

    /// SwifterSwift: UIImage with .alwaysTemplate rendering mode.
    var template: UIImage {
        withRenderingMode(.alwaysTemplate)
    }
}

public extension UIImage {
    func tint(color: UIColor) -> UIImage {
        if #available(iOS 13.0, *) {
            return self.withTintColor(color)
        } else {
            guard let mask = cgImage else { return self }
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

            let format = UIGraphicsImageRendererFormat()
            format.scale = scale
            let renderer = UIGraphicsImageRenderer(size: size, format: format)
            return renderer.image { context in
                let cgContext = context.cgContext
                cgContext.translateBy(x: 0, y: size.height)
                cgContext.scaleBy(x: 1.0, y: -1.0)
                cgContext.clip(to: rect, mask: mask)
                color.setFill()
                context.fill(CGRect(origin: .zero, size: size))
            }
        }
    }
}

// MARK: - Methods

public extension UIImage {
    func cropped(to rect: CGRect) -> UIImage {
        guard rect.size.width <= size.width, rect.size.height <= size.height else { return self }
        let scaledRect = rect.applying(CGAffineTransform(scaleX: scale, y: scale))
        guard let image = cgImage?.cropping(to: scaledRect) else { return self }
        return UIImage(cgImage: image, scale: scale, orientation: imageOrientation)
    }

    func scaled(to scale: CGFloat, opaque: Bool = false) -> UIImage? {
        let toWidth = size.width * scale
        let toHeight = size.height * scale
        return scaled(toWidth: toWidth, toHeight: toHeight, opaque: opaque)
    }

    func scaled(toHeight: CGFloat, opaque: Bool = false) -> UIImage? {
        let scale = toHeight / size.height
        let newWidth = size.width * scale
        return scaled(toWidth: newWidth, toHeight: toHeight, opaque: opaque)
    }

    func scaled(toWidth: CGFloat, opaque: Bool = false) -> UIImage? {
        let scale = toWidth / size.width
        let newHeight = size.height * scale
        return scaled(toWidth: toWidth, toHeight: newHeight, opaque: opaque)
    }

    func scaled(toWidth: CGFloat, toHeight: CGFloat, opaque: Bool = false) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: toWidth, height: toHeight), opaque, scale)
        draw(in: CGRect(x: 0, y: 0, width: toWidth, height: toHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func rotated(by angle: Measurement<UnitAngle>) -> UIImage? {
        let radians = CGFloat(angle.converted(to: .radians).value)

        let destRect = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
        let roundedDestRect = CGRect(x: destRect.origin.x.rounded(),
                                     y: destRect.origin.y.rounded(),
                                     width: destRect.width.rounded(),
                                     height: destRect.height.rounded())

        UIGraphicsBeginImageContextWithOptions(roundedDestRect.size, false, scale)
        guard let contextRef = UIGraphicsGetCurrentContext() else { return nil }

        contextRef.translateBy(x: roundedDestRect.width / 2, y: roundedDestRect.height / 2)
        contextRef.rotate(by: radians)

        draw(in: CGRect(origin: CGPoint(x: -size.width / 2,
                                        y: -size.height / 2),
                        size: size))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func rotated(by radians: CGFloat) -> UIImage? {
        let destRect = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: radians))
        let roundedDestRect = CGRect(x: destRect.origin.x.rounded(),
                                     y: destRect.origin.y.rounded(),
                                     width: destRect.width.rounded(),
                                     height: destRect.height.rounded())

        UIGraphicsBeginImageContextWithOptions(roundedDestRect.size, false, scale)
        guard let contextRef = UIGraphicsGetCurrentContext() else { return nil }

        contextRef.translateBy(x: roundedDestRect.width / 2, y: roundedDestRect.height / 2)
        contextRef.rotate(by: radians)

        draw(in: CGRect(origin: CGPoint(x: -size.width / 2,
                                        y: -size.height / 2),
                        size: size))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func filled(withColor color: UIColor) -> UIImage {
        #if !os(watchOS)
            if #available(tvOS 10.0, *) {
                let format = UIGraphicsImageRendererFormat()
                format.scale = scale
                let renderer = UIGraphicsImageRenderer(size: size, format: format)
                return renderer.image { context in
                    color.setFill()
                    context.fill(CGRect(origin: .zero, size: size))
                }
            }
        #endif

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        guard let context = UIGraphicsGetCurrentContext() else { return self }

        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        context.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let mask = cgImage else { return self }
        context.clip(to: rect, mask: mask)
        context.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }

    func tint(_ color: UIColor, blendMode: CGBlendMode, alpha: CGFloat = 1.0) -> UIImage {
        let drawRect = CGRect(origin: .zero, size: size)

        #if !os(watchOS)
            if #available(tvOS 10.0, *) {
                let format = UIGraphicsImageRendererFormat()
                format.scale = scale
                return UIGraphicsImageRenderer(size: size, format: format).image { context in
                    color.setFill()
                    context.fill(drawRect)
                    draw(in: drawRect, blendMode: blendMode, alpha: alpha)
                }
            }
        #endif

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        let context = UIGraphicsGetCurrentContext()
        color.setFill()
        context?.fill(drawRect)
        draw(in: drawRect, blendMode: blendMode, alpha: alpha)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    func withBackgroundColor(_ backgroundColor: UIColor) -> UIImage {
        #if !os(watchOS)
            if #available(tvOS 10.0, *) {
                let format = UIGraphicsImageRendererFormat()
                format.scale = scale
                return UIGraphicsImageRenderer(size: size, format: format).image { context in
                    backgroundColor.setFill()
                    context.fill(context.format.bounds)
                    draw(at: .zero)
                }
            }
        #endif

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }

        backgroundColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        draw(at: .zero)

        return UIGraphicsGetImageFromCurrentImageContext()!
    }

    /// SwifterSwift: UIImage with rounded corners.
    ///
    /// - Parameters:
    ///   - radius: corner radius (optional), resulting image will be round if unspecified.
    /// - Returns: UIImage with all corners rounded.
    func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
        let maxRadius = min(size.width, size.height) / 2
        let cornerRadius: CGFloat
        if let radius, radius > 0, radius <= maxRadius {
            cornerRadius = radius
        } else {
            cornerRadius = maxRadius
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)

        let rect = CGRect(origin: .zero, size: size)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        draw(in: rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

public extension UIImage {
    struct FlipOptions: OptionSet {
        public typealias RawValue = Int

        public let rawValue: RawValue

        public init(rawValue: RawValue) {
            self.rawValue = rawValue
        }

        /// Converts "↲" to "↲". Does nothing.
        public static let none = FlipOptions([])

        /// Converts "↲" to "↳". Flips like around **vertical** line (Y-axis).
        public static let horizontal = FlipOptions(rawValue: 1 << 0)

        /// Converts "↲" to "↰". Flips like around **horizontal** (X-axis).
        public static let vertical = FlipOptions(rawValue: 1 << 1)

        /// Converts "↲" to "↱". Flips in both directions.
        public static let both = FlipOptions([.horizontal, .vertical])
    }

    func flipped(options: FlipOptions) -> UIImage {
        guard !options.isEmpty, let cgImage else {
            return self
        }

        let rect = CGRect(origin: .zero, size: size)
        return UIGraphicsImageRenderer(size: rect.size).image(actions: { ctx in
            // Reset transformation matrix to default
            ctx.cgContext.concatenate(ctx.cgContext.ctm.inverted())

            // Set original scale
            ctx.cgContext.scaleBy(x: scale, y: scale)

            if options.contains(.vertical) {
                ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
                ctx.cgContext.translateBy(x: 0.0, y: -size.height)
            }
            if options.contains(.horizontal) {
                ctx.cgContext.scaleBy(x: -1.0, y: 1.0)
                ctx.cgContext.translateBy(x: -size.width, y: 0.0)
            }

            ctx.cgContext.draw(cgImage, in: rect)
        })
    }
}

// MARK: - Initializers

public extension UIImage {
    /// SwifterSwift: Create UIImage from color and size.
    ///
    /// - Parameters:
    ///   - color: image fill color.
    ///   - size: image size.
    convenience init(color: UIColor, size: CGSize) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)

        defer {
            UIGraphicsEndImageContext()
        }

        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        guard let aCgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else {
            self.init()
            return
        }

        self.init(cgImage: aCgImage)
    }
}

public extension UIImage {
    static func circleWith(size: CGSize, backgroundColor: UIColor) -> UIImage? {
        defer {
            UIGraphicsEndImageContext()
        }

        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        context.setFillColor(backgroundColor.cgColor)
        context.setStrokeColor(UIColor.clear.cgColor)
        context.addEllipse(in: CGRect(origin: .zero, size: size))
        context.drawPath(using: .fill)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
