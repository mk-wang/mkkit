//
//  UIViewExt.swift
//
//
//  Created by MK on 2021/5/24.
//

import UIKit

public extension UIView {
    var isReadyToConfig: Bool {
        !isEmptyBounds && isEmptySubview
    }

    var isEmptySubview: Bool {
        subviews.isEmpty
    }

    var isEmptyBounds: Bool {
        bounds.size == .zero
    }

    func removeSubviews() {
        let list = subviews
        for view in list {
            view.removeFromSuperview()
        }
    }
}

public extension UIView {
    func border(color: UIColor, width: CGFloat) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }

    func shadow(color: UIColor, opacity: Float? = nil, offset: CGSize? = nil, radius: CGFloat? = nil) {
        layer.shadowColor = color.cgColor
        if let opacity {
            layer.shadowOpacity = opacity
        }
        if let offset {
            layer.shadowOffset = offset
        }
        if let radius {
            layer.shadowRadius = radius
        }
        layer.masksToBounds = false
    }

    func corner(radius: CGFloat,
                mask: CACornerMask = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner],
                borderColor: UIColor? = nil,
                borderWidth: CGFloat? = nil)
    {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.maskedCorners = mask

        if let borderColor {
            layer.borderColor = borderColor.cgColor
        }
        if let borderWidth {
            layer.borderWidth = borderWidth
        }
    }

    func corner(top radius: CGFloat) {
        corner(radius: radius, mask: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
    }

    func corner(bottom radius: CGFloat) {
        corner(radius: radius, mask: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
    }

    func corner(left radius: CGFloat) {
        corner(radius: radius, mask: [.layerMinXMinYCorner, .layerMinXMaxYCorner])
    }

    func corner(right radius: CGFloat) {
        corner(radius: radius, mask: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner])
    }

    func corner(enable: Bool) {
        layer.masksToBounds = enable
    }

    //
    func flip(vertically: Bool) {
        var trans = transform
        if vertically {
            trans = trans.scaledBy(x: 1, y: -1)
        } else {
            trans = trans.scaledBy(x: -1, y: 1)
        }

        transform = trans
    }

    // 重排 subview 的位置
    func flipLayout(subview: UIView, vertically: Bool) {
        var center = subview.center
        let boundsSize = bounds.size

        if vertically {
            center.y = boundsSize.height - center.y
        } else {
            center.x = boundsSize.width - center.x
        }

        subview.center = center
    }

    func rotate(duration: Double, repeatCount: Float? = nil, animKey: String? = nil) {
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = duration
        rotation.isCumulative = true
        rotation.repeatCount = repeatCount ?? Float.greatestFiniteMagnitude
        layer.add(rotation, forKey: animKey)
    }

    func shake(count: Float = 2, for duration: TimeInterval = 0.15, withTranslation translation: Float = 6) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.repeatCount = count
        animation.duration = duration / TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.values = [translation, -translation]
        layer.add(animation, forKey: "shake")
    }

    func applyTransform(withScale scale: CGFloat, anchorPoint: CGPoint) {
        layer.anchorPoint = anchorPoint
        let scale = scale != 0 ? scale : CGFloat.leastNonzeroMagnitude
        let revertScale = 1 / scale
        let xPadding = revertScale * (anchorPoint.x - 0.5) * bounds.width
        let yPadding = revertScale * (anchorPoint.y - 0.5) * bounds.height
        transform = CGAffineTransform(scaleX: scale, y: scale).translatedBy(x: xPadding, y: yPadding)
    }
}

public extension UIView {
    func snapshot(update: Bool) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: frame.size)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: update)
        }
    }

    var snapshotByLayer: UIImage? {
        guard let layer = layer.presentation(), bounds.size.isNotEmpty else {
            return nil
        }

        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }

    func blurSnapshot(radius: CGFloat) -> UIImage? {
        guard let snapshot = snapshotByLayer,
              let image = snapshot.gaussianBlurFilter(radius: radius)
        else {
            return nil
        }
        return image
    }
}

public extension UIView {
    func maskBottom() {
        let maskLayer = CALayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.frame = bounds.insetBy(top: -10000, left: 0, bottom: 0, right: 0)
        layer.mask = maskLayer
    }
}

public extension UIView {
    var topSafeArea: CGFloat {
        safeAreaInsets.top
    }

    var bottomSafeArea: CGFloat {
        safeAreaInsets.bottom
    }

    var safeAreaRect: CGRect {
        bounds.inset(by: safeAreaInsets)
    }

    var safeAreaRectWithBottom: CGRect {
        var insets = safeAreaInsets
        insets.bottom = 0
        return bounds.inset(by: insets)
    }

    var safeAreaRectWithTop: CGRect {
        var insets = safeAreaInsets
        insets.top = 0
        return bounds.inset(by: insets)
    }
}

public extension UIView {
    class func screenShotSafeView() -> UIView? {
        let textField = UITextField()
        textField.isSecureTextEntry = true
        textField.isUserInteractionEnabled = false
        guard let safeView = textField.layer.sublayers?.first?.delegate as? UIView else {
            return nil
        }

        safeView.removeFromSuperview()
        let list = safeView.subviews
        list.forEach { $0.removeFromSuperview() }
        safeView.translatesAutoresizingMaskIntoConstraints = false
        return safeView
    }
}

public extension UIView {
    func findFirstSubview<T>(bfs: Bool = true,
                             _: T.Type? = nil,
                             shouldSkip: ((UIView) -> Bool)? = nil) -> T?
    {
        var result: T?

        visit(root: self, bfs: bfs) { view in
            guard shouldSkip?(view) != true else {
                return []
            }

            if let view = view as? T {
                result = view
                return nil
            }

            return view.subviews
        }

        return result
    }

    func findAllSubviews<T>(bfs: Bool = false,
                            _: T.Type? = nil,
                            shouldSkip: ((UIView) -> Bool)? = nil) -> [T]
    {
        var result: [T] = []

        visit(root: self, bfs: bfs) { view in
            guard shouldSkip?(view) != true else {
                return []
            }

            if let view = view as? T {
                result.append(view)
            }

            return view.subviews
        }

        return result
    }
}

public extension UIView {
    func findFirstSuperView<T>(_: T.Type? = nil) -> T? {
        var aView: UIView? = superview

        while aView != nil {
            if let find = aView as? T {
                return find
            }
            aView = aView?.superview
        }

        return nil
    }

    func findFirstSuperViewBy(name: String) -> UIView? {
        guard let clz = NSClassFromString(name) else {
            return nil
        }
        var aView: UIView? = superview
        while aView != nil {
            if aView?.isKind(of: clz) ?? false {
                return aView
            }
            aView = aView?.superview
        }
        return nil
    }

    var respondingViewController: UIViewController? {
        var responder = next

        while responder != nil {
            if let vc = responder as? UIViewController {
                return vc
            } else {
                responder = responder?.next
            }
        }

        return nil
    }
}

public extension UIView {
    // for simple cases: no transformation applied
    func convertedFrame(of view: UIView, frame: CGRect? = nil) -> CGRect {
        let container = view.superview
        assert(container != nil)

        var rect = frame ?? view.frame
        let center = container!.convert(rect.center, to: self)
        return .init(center: center, size: rect.size)
    }

    func visibleRect(of view: UIView, inset: UIEdgeInsets? = nil) -> CGRect {
        guard let superview = view.superview else {
            return .zero
        }

        let viewFrame = convert(view.frame, from: superview)
        var selfFrame = bounds
        if let inset {
            selfFrame = selfFrame.inset(by: inset)
        }
        let intersection = viewFrame.intersection(selfFrame)
        return intersection
    }
}

public extension UIView {
    func compressionLayout(_ priority: UILayoutPriority = .required, for axis: NSLayoutConstraint.Axis) {
        setContentHuggingPriority(priority, for: axis)
        setContentCompressionResistancePriority(priority, for: axis)
    }

    func pinEdges(to other: UIView) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: other.topAnchor),
            bottomAnchor.constraint(equalTo: other.bottomAnchor),
            leadingAnchor.constraint(equalTo: other.leadingAnchor),
            trailingAnchor.constraint(equalTo: other.trailingAnchor),
        ])
    }
}

public extension UIView {
    private static let kLayerNameGradientBorder = "GradientBorderLayer"

    func gradientBorder(width: CGFloat,
                        colors: [UIColor],
                        startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0),
                        endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0),
                        andRoundCornersWithRadius cornerRadius: CGFloat = 0)
    {
        let existingBorder = gradientBorderLayer()
        let border = existingBorder ?? CAGradientLayer()
        border.frame = CGRect(x: bounds.origin.x, y: bounds.origin.y,
                              width: bounds.size.width + width, height: bounds.size.height + width)
        border.colors = colors.map(\.cgColor)
        border.startPoint = startPoint
        border.endPoint = endPoint

        let mask = CAShapeLayer()
        let maskRect = CGRect(x: bounds.origin.x + width / 2, y: bounds.origin.y + width / 2,
                              width: bounds.size.width - width, height: bounds.size.height - width)
        mask.path = UIBezierPath(roundedRect: maskRect, cornerRadius: cornerRadius).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width

        border.mask = mask

        let exists = (existingBorder != nil)
        if !exists {
            layer.addSublayer(border)
        }
    }

    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { $0.name == UIView.kLayerNameGradientBorder }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }
}

public extension UIView {
    static func runDisableActions(_ block: VoidFunction,
                                  completion: VoidFunction? = nil)
    {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if let completion {
            CATransaction.setCompletionBlock(completion)
        }
        block()
        CATransaction.commit()
    }
}

public extension UIView {
    @discardableResult
    func addVerticalGradientBorder(colors: [UIColor],
                                   lineWidth: CGFloat,
                                   cornerRadius: CGFloat,
                                   locations: [CGFloat]? = nil) -> CAGradientLayer
    {
        addGradientBorder(colors: colors,
                          startPoint: .init(x: 0.5, y: 0),
                          endPoint: .init(x: 0.5, y: 1),
                          lineWidth: lineWidth,
                          cornerRadius: cornerRadius,
                          locations: locations)
    }

    @discardableResult
    func addHorizontalGradientBorder(colors: [UIColor],
                                     lineWidth: CGFloat,
                                     cornerRadius: CGFloat,
                                     locations: [CGFloat]? = nil) -> CAGradientLayer
    {
        addGradientBorder(colors: colors,
                          startPoint: .init(x: 0, y: 0.5),
                          endPoint: .init(x: 1, y: 0.5),
                          lineWidth: lineWidth,
                          cornerRadius: cornerRadius,
                          locations: locations)
    }

    @discardableResult
    func addGradientBorder(colors: [UIColor],
                           startPoint: CGPoint,
                           endPoint: CGPoint,
                           lineWidth: CGFloat,
                           cornerRadius: CGFloat,
                           locations: [CGFloat]? = nil) -> CAGradientLayer
    {
        layer.cornerRadius = cornerRadius
        clipsToBounds = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map(\.cgColor)
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds
        if let locations {
            gradientLayer.locations = locations.map {
                .init(value: $0)
            }
        }

        let shapeLayer = CAShapeLayer()
        let roundedRectPath = UIBezierPath(roundedRect: bounds,
                                           cornerRadius: cornerRadius)
        shapeLayer.path = roundedRectPath.cgPath
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.black.cgColor

        gradientLayer.mask = shapeLayer

        layer.addSublayer(gradientLayer)
        return gradientLayer
    }
}
