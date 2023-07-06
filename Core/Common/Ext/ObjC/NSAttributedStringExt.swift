//
//  NSAttributedStringExt.swift
//
//
//  Created by MK on 2021/7/23.
//

import Foundation
import UIKit

// MARK: - Properties

public extension NSAttributedString {
    var bolded: NSAttributedString {
        guard !string.isEmpty else { return self }

        let pointSize: CGFloat
        if let font = attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
            pointSize = font.pointSize
        } else {
            #if os(tvOS) || os(watchOS)
                pointSize = UIFont.preferredFont(forTextStyle: .headline).pointSize
            #else
                pointSize = UIFont.systemFontSize
            #endif
        }
        return applying(attributes: [.font: UIFont.boldSystemFont(ofSize: pointSize)])
    }

    var underlined: NSAttributedString {
        applying(attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }

    var struckthrough: NSAttributedString {
        applying(attributes: [.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)])
    }

    var center: NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        return applying(attributes: [.paragraphStyle: style])
    }

    var italicized: NSAttributedString {
        guard !string.isEmpty else { return self }

        let pointSize: CGFloat
        if let font = attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
            pointSize = font.pointSize
        } else {
            #if os(tvOS) || os(watchOS)
                pointSize = UIFont.preferredFont(forTextStyle: .headline).pointSize
            #else
                pointSize = UIFont.systemFontSize
            #endif
        }
        return applying(attributes: [.font: UIFont.italicSystemFont(ofSize: pointSize)])
    }

    var attributes: [Key: Any] {
        guard length > 0 else { return [:] }
        return attributes(at: 0, effectiveRange: nil)
    }
}

// MARK: - Methods

public extension NSMutableAttributedString {
    func addAttributes(attributes: [Key: Any]) {
        addAttributes(attributes, range: NSRange(0 ..< length))
    }
}

public extension NSAttributedString {
    /// SwifterSwift: Applies given attributes to the new instance of NSAttributedString initialized with self object.
    ///
    /// - Parameter attributes: Dictionary of attributes.
    /// - Returns: NSAttributedString with applied attributes.
    func applying(attributes: [Key: Any]) -> NSAttributedString {
        guard !string.isEmpty else { return self }

        let copy = NSMutableAttributedString(attributedString: self)
        copy.addAttributes(attributes, range: NSRange(0 ..< length))
        return copy
    }

    func colored(with color: UIColor) -> NSAttributedString {
        applying(attributes: [.foregroundColor: color])
    }

    func applyingParagraph(configure: (NSMutableParagraphStyle) -> Void) -> NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        configure(paragraph)
        let attrs = [NSAttributedString.Key.paragraphStyle: paragraph]
        return applying(attributes: attrs)
    }

    /// SwifterSwift: Apply attributes to substrings matching a regular expression.
    ///
    /// - Parameters:
    ///   - attributes: Dictionary of attributes.
    ///   - pattern: a regular expression to target.
    ///   - options: The regular expression options that are applied to the expression during matching. See NSRegularExpression.Options for possible values.
    /// - Returns: An NSAttributedString with attributes applied to substrings matching the pattern.
    func applying(attributes: [Key: Any],
                  toRangesMatching pattern: String,
                  options: NSRegularExpression.Options = []) -> NSAttributedString
    {
        guard let pattern = try? NSRegularExpression(pattern: pattern, options: options) else { return self }

        let matches = pattern.matches(in: string, options: [], range: NSRange(0 ..< length))
        let result = NSMutableAttributedString(attributedString: self)

        for match in matches {
            result.addAttributes(attributes, range: match.range)
        }

        return result
    }

    /// SwifterSwift: Apply attributes to occurrences of a given string.
    ///
    /// - Parameters:
    ///   - attributes: Dictionary of attributes.
    ///   - target: a subsequence string for the attributes to be applied to.
    /// - Returns: An NSAttributedString with attributes applied on the target string.
    func applying(attributes: [Key: Any],
                  toOccurrencesOf target: some StringProtocol) -> NSAttributedString
    {
        let pattern = "\\Q\(target)\\E"

        return applying(attributes: attributes, toRangesMatching: pattern)
    }
}

// MARK: - Operators

public extension NSAttributedString {
    /// SwifterSwift: Add a NSAttributedString to another NSAttributedString.
    ///
    /// - Parameters:
    ///   - lhs: NSAttributedString to add to.
    ///   - rhs: NSAttributedString to add.
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        lhs = string
    }

    /// SwifterSwift: Add a NSAttributedString to another NSAttributedString and return a new NSAttributedString instance.
    ///
    /// - Parameters:
    ///   - lhs: NSAttributedString to add.
    ///   - rhs: NSAttributedString to add.
    /// - Returns: New instance with added NSAttributedString.
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        return NSAttributedString(attributedString: string)
    }

    /// SwifterSwift: Add a NSAttributedString to another NSAttributedString.
    ///
    /// - Parameters:
    ///   - lhs: NSAttributedString to add to.
    ///   - rhs: String to add.
    static func += (lhs: inout NSAttributedString, rhs: String) {
        lhs += NSAttributedString(string: rhs)
    }

    /// SwifterSwift: Add a NSAttributedString to another NSAttributedString and return a new NSAttributedString instance.
    ///
    /// - Parameters:
    ///   - lhs: NSAttributedString to add.
    ///   - rhs: String to add.
    /// - Returns: New instance with added NSAttributedString.
    static func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
        lhs + NSAttributedString(string: rhs)
    }
}

public extension NSAttributedString {
    /**
     Applies a font to the entire string.

     - parameter font: The font.
     */
    @discardableResult
    func font(_ font: UIFont) -> NSAttributedString {
        applying(attributes: [.font: font])
    }
}
