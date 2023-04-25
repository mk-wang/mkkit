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
    var highlightedTextColor: UIColor? {
        get
    }

    var highlightedBackgroundColor: UIColor? {
        get
    }

    var disabledColor: UIColor? {
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

public extension UITextView {
    convenience init(text: String, style: TextViewStyle) {
        self.init()
        self.text = text
        font = style.font
        textColor = style.color
        textAlignment = style.textAlignment
        backgroundColor = style.backgroundColor
        layer.cornerRadius = style.cornerRadius
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

        if let color = style.highlightedTextColor {
            setTitleColor(color, for: .highlighted)
        }
        if let btn = self as? YXButton {
            btn.setBackgroundColor(style.highlightedBackgroundColor, for: .highlighted)
            btn.setBackgroundColor(style.backgroundColor, for: .normal)
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
    let hightlightTextColorBuilder: (() -> UIColor)?
    let disabledColorBuilder: (() -> UIColor)?

    public let cornerRadius: CGFloat

    public init(font: UIFont,
                textAlignment: NSTextAlignment = .start,
                cornerRadius: CGFloat = 0,
                colorBuilder: @escaping () -> UIColor,
                disabledColorBuilder: (() -> UIColor)? = nil,
                backgourndColorBuilder: (() -> UIColor)? = nil,
                hightlightColorBuilder: (() -> UIColor)? = nil,
                hightlightTextColorBuilder: (() -> UIColor)? = nil)
    {
        self.font = font
        self.textAlignment = textAlignment
        self.cornerRadius = cornerRadius
        self.colorBuilder = colorBuilder
        self.disabledColorBuilder = disabledColorBuilder
        self.backgourndColorBuilder = backgourndColorBuilder
        self.hightlightColorBuilder = hightlightColorBuilder
        self.hightlightTextColorBuilder = hightlightTextColorBuilder
    }
}

// MARK: ButtonViewStyle

extension AppViewStyle: ButtonViewStyle {
    public var color: UIColor {
        colorBuilder()
    }

    public var backgroundColor: UIColor {
        backgourndColorBuilder == nil ? .clear : backgourndColorBuilder!()
    }

    public var disabledColor: UIColor? {
        disabledColorBuilder?()
    }

    public var highlightedTextColor: UIColor? {
        hightlightTextColorBuilder?()
    }

    public var highlightedBackgroundColor: UIColor? {
        hightlightColorBuilder?()
    }
}
