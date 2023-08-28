//
//  TextViewStyle.swift
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
}

public extension TextViewStyle {
    var textAttributes: [NSAttributedString.Key: Any] {
        makeTextAttributes()
    }

    func makeTextAttributes(paragraphConfigure: ((NSMutableParagraphStyle) -> Void)? = nil) -> [NSAttributedString.Key: Any] {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = textAlignment
        paragraphConfigure?(paragraph)
        return [NSAttributedString.Key.font: font,
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.backgroundColor: backgroundColor,
                NSAttributedString.Key.paragraphStyle: paragraph]
    }
}

// MARK: - ButtonViewStyle

public protocol ButtonViewStyle: TextViewStyle {
    var highlightedTextColor: UIColor? {
        get
    }

    var highlightedImageColor: UIColor? {
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
}

public extension UILabel {
    convenience init(text: String, style: TextViewStyle) {
        self.init()
        self.text = text
        font = style.font
        textColor = style.color
        textAlignment = style.textAlignment
        backgroundColor = style.backgroundColor
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
    }
}

public extension UIButton {
    convenience init(type: UIButton.ButtonType, style: ButtonViewStyle) {
        self.init(type: type)

        titleLabel?.font = style.font
        setTitleColor(style.color, for: .normal)

        titleLabel?.textAlignment = style.textAlignment
        backgroundColor = style.backgroundColor

        if let color = style.highlightedTextColor {
            setTitleColor(color, for: .highlighted)
        }
        if let btn = self as? MKButton {
            btn.setBackgroundColor(style.highlightedBackgroundColor, for: .highlighted)
            btn.setBackgroundColor(style.backgroundColor, for: .normal)
        }
    }
}

public extension NSAttributedString {
    convenience init(text: String, style: TextViewStyle, paragraphConfigure: ((NSMutableParagraphStyle) -> Void)? = nil) {
        self.init(string: text,
                  attributes: style.makeTextAttributes(paragraphConfigure: paragraphConfigure))
    }
}

// MARK: - AppViewStyle

public struct AppViewStyle {
    public let font: UIFont

    let colorBuilder: () -> UIColor
    let textAlignmentBuilder: (() -> NSTextAlignment)?
    let backgourndColorBuilder: (() -> UIColor)?
    let highlightTextColorBuilder: (() -> UIColor)?
    let highlightImageColorBuilder: (() -> UIColor)?
    let highlightBackgroundColorBuilder: (() -> UIColor)?

    let disabledColorBuilder: (() -> UIColor)?

    public init(font: UIFont,
                textAlignmentBuilder: (() -> NSTextAlignment)? = nil,
                colorBuilder: @escaping () -> UIColor,
                disabledColorBuilder: (() -> UIColor)? = nil,
                backgourndColorBuilder: (() -> UIColor)? = nil,
                highlightTextColorBuilder: (() -> UIColor)? = nil,
                highlightImageColorBuilder: (() -> UIColor)? = nil,
                highlightBackgroundColorBuilder: (() -> UIColor)? = nil)
    {
        self.font = font
        self.textAlignmentBuilder = textAlignmentBuilder
        self.colorBuilder = colorBuilder
        self.disabledColorBuilder = disabledColorBuilder
        self.backgourndColorBuilder = backgourndColorBuilder
        self.highlightBackgroundColorBuilder = highlightBackgroundColorBuilder
        self.highlightImageColorBuilder = highlightImageColorBuilder
        self.highlightTextColorBuilder = highlightTextColorBuilder
    }
}

// MARK: ButtonViewStyle

extension AppViewStyle: ButtonViewStyle {
    public var textAlignment: NSTextAlignment {
        textAlignmentBuilder?() ?? .start
    }

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
        highlightTextColorBuilder?()
    }

    public var highlightedImageColor: UIColor? {
        highlightImageColorBuilder?()
    }

    public var highlightedBackgroundColor: UIColor? {
        highlightBackgroundColorBuilder?()
    }
}
