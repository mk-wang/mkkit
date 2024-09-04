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

    func makeTextAttributes(paragraphConfigure: VoidFunction1<NSMutableParagraphStyle>? = nil)
        -> [NSAttributedString.Key: Any]
    {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = textAlignment
        paragraphConfigure?(paragraph)

        return [.font: font,
                .foregroundColor: color,
                .backgroundColor: backgroundColor,
                .paragraphStyle: paragraph]
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
    convenience init(text: String?,
                     style: TextViewStyle,
                     numberOfLines: Int = 0,
                     adjustsFontSizeToFitWidth: Bool = false,
                     asAttributedText: Bool = false,
                     paragraphConfigure: VoidFunction1<NSMutableParagraphStyle>? = nil)
    {
        self.init()

        if asAttributedText {
            attributedText = text?.attributedString(attrs:
                style.makeTextAttributes(paragraphConfigure: paragraphConfigure)
            )
        } else {
            self.text = text
        }

        self.numberOfLines = numberOfLines
        self.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        applyTextStyle(style: style)
    }

    func applyTextStyle(style: TextViewStyle) {
        font = style.font
        textColor = style.color
        textAlignment = style.textAlignment
        backgroundColor = style.backgroundColor
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

    func applyTextStyle(style: TextViewStyle) {
        font = style.font
        textColor = style.color
        textAlignment = style.textAlignment
        backgroundColor = style.backgroundColor
    }
}

public extension NSAttributedString {
    convenience init(text: String,
                     style: TextViewStyle,
                     paragraphConfigure: VoidFunction1<NSMutableParagraphStyle>? = nil)
    {
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
