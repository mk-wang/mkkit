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
        attributedString(range: startIndex ..< endIndex,
                         attrs: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue])
    }

    func attributedString(range: Range<Self.Index>, attrs: [NSAttributedString.Key: Any]) -> NSAttributedString {
        NSAttributedString(string: String(self[range]), attributes: attrs)
    }

    func makeAttrByTags(normal: [NSAttributedString.Key: Any],
                        tagAttrs: [String: [NSAttributedString.Key: Any]]) -> NSAttributedString
    {
        let mStr = NSMutableAttributedString()
        var search = startIndex ..< endIndex

        while !search.isEmpty {
            var tag: String?
            var start: Range<Self.Index>?

            for (key, attrs) in tagAttrs {
                if let found = range(of: "<\(key)>", range: search) {
                    let lower = found.lowerBound
                    if start == nil || start!.lowerBound > lower {
                        start = found
                        tag = key
                    }
                }
            }

            if let tag,
               let start,
               let end = range(of: "</\(tag)>", range: search),
               let attrs = tagAttrs[tag]
            {
                var text = attributedString(range: search.lowerBound ..< start.lowerBound,
                                            attrs: normal)
                if text.length > 0 {
                    mStr.append(text)
                }

                text = attributedString(range: start.upperBound ..< end.lowerBound,
                                        attrs: attrs)
                if text.length > 0 {
                    mStr.append(text)
                }

                search = end.upperBound ..< endIndex
            } else {
                let text = attributedString(range: search,
                                            attrs: normal)
                if text.length > 0 {
                    mStr.append(text)
                }
                break
            }
        }

        return mStr
    }

    func makeAttrByTag(normal: [NSAttributedString.Key: Any],
                       tag: String,
                       tagAttrs: [NSAttributedString.Key: Any]) -> NSAttributedString
    {
        makeAttrByTags(normal: normal,
                       tagAttrs: [tag: tagAttrs])
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
