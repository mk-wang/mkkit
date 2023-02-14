//
//  StringExt.swift
//
//
//  Created by MK on 2021/6/4.
//

import Foundation
import UIKit

public func rotNumber(_ value: UInt32, n: UInt8) -> UInt32 {
    var result = value

    if 65 ... 90 ~= result {
        result = (result + UInt32(n) - 65) % 26 + 65
    } else if 97 ... 122 ~= result {
        result = (result + UInt32(n) - 97) % 26 + 97
    }

    return result
}

public extension String {
    func rot(n: UInt8) -> Self {
        String(unicodeScalars.map {
            let value = rotNumber(UInt32($0.value), n: n)
            return Character(Unicode.Scalar(value)!)
        })
    }

    var utf8Data: Data? {
        data(using: .utf8, allowLossyConversion: true)
    }

    var utf8Base64Str: String? {
        utf8Data?.base64EncodedString()
    }

    var jsonObject: Any? {
        utf8Data?.jsonObject
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}

public extension String {
    func textViewSize(font: UIFont, width: CGFloat? = nil, height: CGFloat? = nil) -> CGSize {
        let attrString = NSAttributedString(string: self, attributes: [NSAttributedString.Key.font: font])
        let drawSize = CGSize(width ?? CGFloat.greatestFiniteMagnitude, height ?? CGFloat.greatestFiniteMagnitude)
        let boundingRect = attrString.boundingRect(with: drawSize,
                                                   options: .usesLineFragmentOrigin,
                                                   context: nil)

        //  https://developer.apple.com/documentation/uikit/uifont?language=objc
        let bottomPadding = boundingRect.origin.y - font.descender
        let height = boundingRect.size.height + bottomPadding
        return CGSize(boundingRect.size.width, height)
    }
}

public extension String {
    var underline: NSAttributedString {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
        return NSAttributedString(string: self, attributes: underlineAttribute)
    }

    func makeAttrByTag(openTag: String,
                       closeTag: String,
                       attrs: [NSAttributedString.Key: Any],
                       tagAttrs: [NSAttributedString.Key: Any]) -> NSAttributedString
    {
        let mStr = NSMutableAttributedString()
        guard let startRange = range(of: openTag), let endRange = range(of: closeTag) else {
            mStr.append(NSAttributedString(string: self, attributes: attrs))
            return mStr
        }
        let start = String(self[..<startRange.lowerBound])
        if start.isNotEmpty {
            mStr.append(NSAttributedString(string: start, attributes: attrs))
        }

        let boldText = String(self[startRange.upperBound ..< endRange.lowerBound])
        if boldText.isNotEmpty {
            mStr.append(NSAttributedString(string: boldText, attributes: tagAttrs))
        }
        let end = String(self[endRange.upperBound...])
        if end.isNotEmpty {
            mStr.append(NSAttributedString(string: end, attributes: attrs))
        }
        return mStr
    }

    func makeAttrByTag(tag: String,
                       attrs: [NSAttributedString.Key: Any],
                       tagAttrs: [NSAttributedString.Key: Any]) -> NSAttributedString
    {
        let mStr = NSMutableAttributedString()
        guard let startRange = range(of: "<\(tag)>"), let endRange = range(of: "</\(tag)>") else {
            mStr.append(NSAttributedString(string: self, attributes: attrs))
            return mStr
        }
        let start = String(self[..<startRange.lowerBound])
        if start.isNotEmpty {
            mStr.append(NSAttributedString(string: start, attributes: attrs))
        }

        let boldText = String(self[startRange.upperBound ..< endRange.lowerBound])
        if boldText.isNotEmpty {
            mStr.append(NSAttributedString(string: boldText, attributes: tagAttrs))
        }
        let end = String(self[endRange.upperBound...])
        if end.isNotEmpty {
            mStr.append(NSAttributedString(string: end, attributes: attrs))
        }
        return mStr
    }
}

extension String {
    var md5: String? {
        data(using: .utf8)?.md5
    }
}

extension String {
    public func substring(from index: Int) -> String? {
        if count > index {
            let startIndex = self.index(startIndex, offsetBy: index)
            let subString = self[startIndex ..< endIndex]

            return String(subString)
        } else {
            return nil
        }
    }

    public func substring(to end: Int) -> String {
        let limit = min(count, end)
        let endIndex = index(startIndex, offsetBy: limit)
        let subString = self[startIndex ..< endIndex]

        return String(subString)
    }

    func changeFirstChar(upCase: Bool) -> Self {
        if count > 2 {
            return String(prefix(1)).changeFirstChar(upCase: upCase) + substring(from: 1)!
        } else {
            return upCase ? localizedCapitalized : localizedLowercase
        }
    }

    func replaceCharactersFromSet(characterSet: CharacterSet, replacementString: String = "") -> String {
        components(separatedBy: characterSet).joined(separator: replacementString)
    }
}

extension StringProtocol {
    func index(of string: some StringProtocol, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.lowerBound
    }

    func endIndex(of string: some StringProtocol, options: String.CompareOptions = []) -> Index? {
        range(of: string, options: options)?.upperBound
    }

    func indices(of string: some StringProtocol, options: String.CompareOptions = []) -> [Index] {
        ranges(of: string, options: options).map(\.lowerBound)
    }

    func ranges(of string: some StringProtocol, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = startIndex
        while startIndex < endIndex,
              let range = self[startIndex...]
              .range(of: string, options: options)
        {
            result.append(range)
            startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

extension String {
    static var rtlSeparator: String {
        "،"
    }

    static var ltrSeparator: String {
        ","
    }
}
