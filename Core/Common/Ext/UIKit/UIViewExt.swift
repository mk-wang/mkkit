//
//  UIViewExt.swift
//
//
//  Created by MK on 2021/5/24.
//

import UIKit

public extension UIView {
    func removeSubviews() {
        let list = subviews
        for view in list {
            view.removeFromSuperview()
        }
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
}

public extension UIView {
    var snapshot: UIImage {
        let renderer = UIGraphicsImageRenderer(size: frame.size)
        return renderer.image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
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
