//
//  LangRTL.swift
//
//
//  Created by MK on 2021/9/3.
//

import Foundation
import UIKit

public extension Lang {
    var isRTL: Bool {
        self == .ar
    }

    func configDirection() {
        let list = [UITabBar.appearance(),
                    UISlider.appearance(),
                    UITextField.appearance(),
                    UIStackView.appearance(),
                    UIScrollView.appearance(),
                    UINavigationBar.appearance(),
                    UIView.appearance()]
        let direction: UISemanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight
        list.forEach { $0.semanticContentAttribute = direction }
    }
}

public extension UIView {
    func force(rtl: Bool, withSubview: Bool) {
        let direction: UISemanticContentAttribute = rtl ? .forceRightToLeft : .forceLeftToRight
        semanticContentAttribute = direction
        if withSubview {
            subviews.forEach { $0.force(rtl: rtl, withSubview: true) }
        }
    }

    var preferRTL: Bool {
        effectiveUserInterfaceLayoutDirection == .rightToLeft
    }

    func applayLangConfig() {
        let direction: UISemanticContentAttribute = Lang.current.isRTL ? .forceRightToLeft : .forceLeftToRight
        semanticContentAttribute = direction
    }

    func corner(start radius: CGFloat) {
        if Lang.current.isRTL {
            corner(right: radius)
        } else {
            corner(left: radius)
        }
    }

    func corner(end radius: CGFloat) {
        if Lang.current.isRTL {
            corner(left: radius)
        } else {
            corner(right: radius)
        }
    }
}

public extension UIImage {
    var langFlip: UIImage {
        guard Lang.current.isRTL else {
            return self
        }
        // ios 13 以下有问题
        if #available(iOS 13.0, *) {
            return withHorizontallyFlippedOrientation()
        } else {
            return flipped(options: .horizontal)
        }
    }
}

public extension UIEdgeInsets {
    var langFlip: Self {
        guard Lang.current.isRTL else {
            return self
        }
        return Self(top: top, left: right, bottom: bottom, right: left)
    }

    var start: CGFloat {
        Lang.current.isRTL ? right : left
    }

    var end: CGFloat {
        Lang.current.isRTL ? left : right
    }

    var directionalEdgeInsets: NSDirectionalEdgeInsets {
        .init(top: top, leading: start, bottom: bottom, trailing: end)
    }

    static func only(top: CGFloat = 0, start: CGFloat = 0, bottom: CGFloat = 0, end: CGFloat = 0) -> Self {
        if Lang.current.isRTL {
            return UIEdgeInsets(top: top, left: end, bottom: bottom, right: start)
        } else {
            return UIEdgeInsets(top: top, left: start, bottom: bottom, right: end)
        }
    }
}

public extension NSDirectionalEdgeInsets {
    var edgeInsets: UIEdgeInsets {
        .only(top: top, start: leading, bottom: bottom, end: trailing)
    }
}

public extension NSTextAlignment {
    static var start: NSTextAlignment {
        Lang.current.isRTL ? .right : .left
    }

    static var end: NSTextAlignment {
        Lang.current.isRTL ? .left : .right
    }
}

// UITextField 非常特殊
public extension UITextField {
    var startView: UIView? {
        get {
            leftView
        }
        set {
            leftView = newValue
        }
    }

    var startViewMode: ViewMode {
        get {
            leftViewMode
        }
        set {
            leftViewMode = newValue
        }
    }

    var endView: UIView? {
        get {
            rightView
        }
        set {
            rightView = newValue
        }
    }

    var endViewMode: ViewMode {
        get {
            rightViewMode
        }
        set {
            rightViewMode = newValue
        }
    }
}

public extension UINavigationController {
    func applayLangConfig() {
        let direction: UISemanticContentAttribute = Lang.current.isRTL ? .forceRightToLeft : .forceLeftToRight
        view.semanticContentAttribute = direction
        navigationBar.semanticContentAttribute = direction
    }
}
