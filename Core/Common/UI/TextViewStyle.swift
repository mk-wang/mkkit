//
//  TextStyle.swift
//
//
//  Created by MK on 2022/3/24.
//

import UIKit

// MARK: - TextViewStyle

public protocol TextViewStyle {
    var font: UIFont {
        get
    }

    var color: UIColor {
        get
    }

    var textAlignment: NSTextAlignment {
        get
    }

    var backgroundColor: UIColor {
        get
    }

    var cornerRadius: CGFloat {
        get
    }
}

// MARK: - ButtonViewStyle

public protocol ButtonViewStyle: TextViewStyle {
    var hilightColor: UIColor? {
        get
    }
}

public extension TextViewStyle {
    var backgroundColor: UIColor {
        .clear
    }

    var cornerRadius: CGFloat {
        0
    }
}

public extension UILabel {
    convenience init(text: String, style: TextViewStyle) {
        self.init()
        self.text = text
        font = style.font
        textColor = style.color
        textAlignment = style.textAlignment
        backgroundColor = style.backgroundColor
        layer.cornerRadius = style.cornerRadius
        numberOfLines = 0
    }
}

public extension UIButton {
    convenience init(type: UIButton.ButtonType, style: ButtonViewStyle) {
        self.init(type: type)

        titleLabel?.font = style.font
        setTitleColor(style.color, for: .normal)

        titleLabel?.textAlignment = style.textAlignment
        backgroundColor = style.backgroundColor
        layer.cornerRadius = style.cornerRadius

        if let color = style.hilightColor {
            setTitleColor(color, for: .highlighted)
        }
    }
}

public extension NSAttributedString {
    convenience init(text: String, style: TextViewStyle) {
        self.init(string: text,
                  attributes: [NSAttributedString.Key.font: style.font,
                               NSAttributedString.Key.backgroundColor: style.backgroundColor,
                               NSAttributedString.Key.foregroundColor: style.color])
    }
}

// MARK: - AppViewStyle

public struct AppViewStyle {
    public let font: UIFont
    public let textAlignment: NSTextAlignment

    let colorBuilder: () -> UIColor
    let backgourndColorBuilder: (() -> UIColor)?
    let hightlightColorBuilder: (() -> UIColor)?

    public let cornerRadius: CGFloat

    init(font: UIFont,
         textAlignment: NSTextAlignment = .start,
         cornerRadius: CGFloat = 0,
         colorBuilder: @escaping () -> UIColor,
         backgourndColorBuilder: (() -> UIColor)? = nil,
         hightlightColorBuilder: (() -> UIColor)? = nil)
    {
        self.font = font
        self.textAlignment = textAlignment
        self.cornerRadius = cornerRadius
        self.colorBuilder = colorBuilder
        self.backgourndColorBuilder = backgourndColorBuilder
        self.hightlightColorBuilder = hightlightColorBuilder
    }
}

// MARK: ButtonViewStyle

extension AppViewStyle: ButtonViewStyle {
    public var color: UIColor {
        colorBuilder()
    }

    public var backgroundColor: UIColor {
        guard let builder = backgourndColorBuilder else {
            return .clear
        }
        return builder()
    }

    public var hilightColor: UIColor? {
        guard let builder = hightlightColorBuilder else {
            return nil
        }
        return builder()
    }
}
