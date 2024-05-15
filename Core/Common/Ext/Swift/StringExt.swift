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
    static func equalIngoreNil(_ lhs: Self?, _ rhs: Self?) -> Bool {
        lhs == rhs || ((lhs?.isEmpty ?? true) && (rhs?.isEmpty ?? true))
    }
}

public extension String {
    func convert(predicate: ValueBuilder1<Bool, String>, builder: ValueBuilder1<String, String>) -> String {
        predicate(self) ? builder(self) : self
    }
}

public extension String {
    func rot(n: UInt8) -> String {
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

    var utf8List: [UInt8] {
        Array(utf8)
    }
}

public extension String {
    func textViewSize(font: UIFont, fixBottomPadding: Bool = false, width: CGFloat? = nil, height: CGFloat? = nil) -> CGSize {
        let attrString = NSAttributedString(string: self, attributes: [.font: font])
        return attrString.textViewSize(font: font, fixBottomPadding: fixBottomPadding, width: width, height: height)
    }
}

public extension String {
    var singleUnderline: NSAttributedString {
        NSAttributedString(string: self, attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }

    var thickUnderline: NSAttributedString {
        NSAttributedString(string: self, attributes: [.underlineStyle: NSUnderlineStyle.thick.rawValue])
    }

    var singleStruckthrough: NSAttributedString {
        NSAttributedString(string: self, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue])
    }

    var thickStruckthrough: NSAttributedString {
        NSAttributedString(string: self, attributes: [.strikethroughStyle: NSUnderlineStyle.thick.rawValue])
    }

    func attributedString(range: Range<Self.Index>, attrs: [NSAttributedString.Key: Any]) -> NSAttributedString {
        NSAttributedString(string: String(self[range]), attributes: attrs)
    }

    func attributedString(attrs: [NSAttributedString.Key: Any]) -> NSAttributedString {
        NSAttributedString(string: self, attributes: attrs)
    }

    func makeAttrByTags(normal: [NSAttributedString.Key: Any],
                        tagAttrs: [String: [NSAttributedString.Key: Any]]) -> NSMutableAttributedString
    {
        let mStr = NSMutableAttributedString()
        var search = startIndex ..< endIndex

        while !search.isEmpty {
            var tag: String?
            var start: Range<Self.Index>?

            for (key, attrs) in tagAttrs {
                if let found = range(of: "<\(key)>", range: search) {
                    if start == nil || start!.lowerBound > found.lowerBound {
                        tag = key
                        start = found
                    }
                }
            }

            if let tag,
               let start,
               let attrs = tagAttrs[tag],
               let end = range(of: "</\(tag)>", range: search)
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
                       tagAttrs: [NSAttributedString.Key: Any]) -> NSMutableAttributedString
    {
        makeAttrByTags(normal: normal,
                       tagAttrs: [tag: tagAttrs])
    }

    //
    func makeAttrByFormat(key: String = "%@",
                          attrs: [NSAttributedString.Key: Any],
                          param: String,
                          paramAttrs: [NSAttributedString.Key: Any]) -> NSMutableAttributedString
    {
        guard !key.isEmpty else {
            return NSMutableAttributedString(string: self, attributes: attrs)
        }
        let parts = components(separatedBy: key)
        guard parts.count == 2 else {
            return NSMutableAttributedString(string: self, attributes: attrs)
        }
        let mStr = NSMutableAttributedString()
        if let text = parts.first, text.isNotEmpty {
            mStr.append(.init(string: text, attributes: attrs))
        }
        mStr.append(NSAttributedString(string: param, attributes: paramAttrs))
        if let text = parts.last, text.isNotEmpty {
            mStr.append(.init(string: text, attributes: attrs))
        }

        return mStr
    }
}

public extension String {
    var md5: String? {
        data(using: .utf8)?.md5
    }

    func scanInteger(_ charSet: CharacterSet = .decimalDigits) -> Int? {
        var numberString: NSString?

        let scanner = Scanner(string: self)
        scanner.scanUpToCharacters(from: charSet, into: nil)
        scanner.scanCharacters(from: charSet, into: &numberString)

        return numberString?.integerValue
    }
}

public extension String {
    func substring(from index: Int) -> String? {
        if count > index {
            let startIndex = self.index(startIndex, offsetBy: index)
            let subString = self[startIndex ..< endIndex]

            return String(subString)
        } else {
            return nil
        }
    }

    func substring(to end: Int) -> String {
        let limit = min(count, end)
        let endIndex = index(startIndex, offsetBy: limit)
        let subString = self[startIndex ..< endIndex]

        return String(subString)
    }

    func changeFirstChar(upCase: Bool) -> Self {
        if count > 2 {
            String(prefix(1)).changeFirstChar(upCase: upCase) + substring(from: 1)!
        } else {
            upCase ? localizedCapitalized : localizedLowercase
        }
    }

    func replaceCharactersFromSet(characterSet: CharacterSet, replacementString: String = "") -> String {
        components(separatedBy: characterSet).joined(separator: replacementString)
    }
}

public extension StringProtocol {
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

public extension StringProtocol {
    subscript(_ offset: Int) -> Element { self[index(startIndex, offsetBy: offset)] }
    subscript(_ range: Range<Int>) -> SubSequence { prefix(range.lowerBound + range.count).suffix(range.count) }
    subscript(_ range: ClosedRange<Int>) -> SubSequence { prefix(range.lowerBound + range.count).suffix(range.count) }
    subscript(_ range: PartialRangeThrough<Int>) -> SubSequence { prefix(range.upperBound.advanced(by: 1)) }
    subscript(_ range: PartialRangeUpTo<Int>) -> SubSequence { prefix(range.upperBound) }
    subscript(_ range: PartialRangeFrom<Int>) -> SubSequence { suffix(Swift.max(0, count - range.lowerBound)) }
}

/// https://stackoverflow.com/questions/28079123/how-to-check-validity-of-url-in-swift
public extension String {
    var isValidURL: Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)

        guard detector != nil, isNotEmpty else {
            return false
        }
        if detector!.numberOfMatches(in: self,
                                     options: NSRegularExpression.MatchingOptions(rawValue: 0),
                                     range: NSMakeRange(0, count)) > 0
        {
            return true
        }
        return false
    }
}

public extension String {
    var localizableText: String {
        var text = replacingOccurrences(of: #"\"#, with: #"\\"#)
        text = text.replacingOccurrences(of: "\n", with: #"\n"#)
        text = text.replacingOccurrences(of: #"""#, with: #"\""#)
        return text
    }
}

public extension String {
    var trimmedText: String {
        trimmingCharacters(in: .whitespaces)
    }

    var leadingTrimmedText: String {
        guard let index = firstIndex(where: { !$0.isWhitespace }) else {
            return ""
        }
        return String(self[index...])
    }

    var trailingTrimmedText: String {
        guard let index = lastIndex(where: { !$0.isWhitespace }) else {
            return ""
        }
        return String(self[...index])
    }

    var trimmedAllText: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var leadingTrimmedAllText: String {
        guard let index = firstIndex(where: { !$0.isWhitespace && !$0.isNewline }) else {
            return ""
        }
        return String(self[index...])
    }

    var trailingTrimmedAllText: String {
        guard let index = lastIndex(where: { !$0.isWhitespace && !$0.isNewline }) else {
            return ""
        }
        return String(self[...index])
    }
}

public extension String {
    static var rtlSeparator: String {
        "،"
    }

    static var ltrSeparator: String {
        ","
    }
}

public extension String {
    var fileURL: URL {
        if #available(iOS 16.0, *) {
            .init(filePath: self)
        } else {
            .init(fileURLWithPath: self)
        }
    }

    var url: URL? {
        URL(string: self)
    }
}

public extension String {
    var isDecimalDigits: Bool {
        let characters = CharacterSet.decimalDigits
        return CharacterSet(charactersIn: self).isSubset(of: characters)
    }

    var isNumber: Bool {
        allSatisfy { character in
            character.isNumber
        }
    }

    var isWholeNumber: Bool {
        allSatisfy { character in
            character.isWholeNumber
        }
    }
}

// from https://raw.githubusercontent.com/tbaranes/FittableFontLabel/master/Source/UILabelExtension.swift
extension String {
    public static func fontSizeThatFits(
        texts: [String],
        font: UIFont,
        numberOfLines: Int,
        rectSize: CGSize,
        fitter: CGFloat,
        maxFontSize: CGFloat,
        minFontScale: CGFloat = 0.1
    ) -> CGFloat {
        var fontSize = maxFontSize

        for text in texts {
            let value = text.fontSizeThatFits(font: font,
                                              numberOfLines: numberOfLines,
                                              rectSize: rectSize,
                                              fitter: fitter,
                                              maxFontSize: maxFontSize,
                                              minFontScale: minFontScale)
            if fontSize > value {
                fontSize = value
            }
        }

        return fontSize
    }

    /**
     Returns a font size of a specific string in a specific font that fits a specific size

     - parameter text:         The text to use
     - parameter maxFontSize:  The max font size available
     - parameter minFontScale: The min font scale that the font will have
     - parameter rectSize:     Rect size where the label must fit
     */
    public func fontSizeThatFits(font: UIFont,
                                 numberOfLines: Int,
                                 rectSize: CGSize,
                                 fitter: CGFloat,
                                 maxFontSize: CGFloat,
                                 minFontScale: CGFloat = 0.1) -> CGFloat
    {
        let maxFontSize = maxFontSize.isNaN ? 100 : maxFontSize
        let minFontScale = minFontScale.isNaN ? 0.1 : minFontScale
        let minimumFontSize = maxFontSize * minFontScale

        guard !isEmpty else {
            return font.pointSize
        }

        let constraintSize = numberOfLines == 1 ?
            CGSize(width: .greatestFiniteMagnitude, height: rectSize.height) :
            CGSize(width: rectSize.width, height: .greatestFiniteMagnitude)

        let calculatedFontSize = Self.binarySearch(string: self,
                                                   font: font,
                                                   numberOfLines: numberOfLines,
                                                   fitter: fitter,
                                                   minSize: minimumFontSize,
                                                   maxSize: maxFontSize,
                                                   size: rectSize,
                                                   constraintSize: constraintSize)
        return (calculatedFontSize * 10.0 - 2).rounded(.down) / 10.0
    }

    private static func binarySearch(string: String,
                                     font: UIFont,
                                     numberOfLines: Int,
                                     fitter: CGFloat,
                                     minSize: CGFloat,
                                     maxSize: CGFloat,
                                     size: CGSize,
                                     constraintSize: CGSize) -> CGFloat
    {
        let fontSize = (minSize + maxSize) / 2
        let newFont = font.withSize(fontSize)
        //        var attributes = currentAttributedStringAttributes()
        //        attributes[Key.font] = font.withSize(fontSize)
        //        let textSize = string.boundingRect(with: constraintSize, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        let textSize = string.textViewSize(font: newFont, width: constraintSize.width, height: constraintSize.height)
        let state = numberOfLines == 1 ? singleLineSizeState(rectSize: textSize, size: size, fitter: fitter)
            : multiLineSizeState(rectSize: textSize, size: size, fitter: fitter)

        // if the search range is smaller than 0.1 of a font size we stop
        // returning either side of min or max depending on the state
        let diff = maxSize - minSize
        guard diff > 0.1 else {
            switch state {
            case .tooSmall:
                return maxSize
            default:
                return minSize
            }
        }

        switch state {
        case .fit: return fontSize
        case .tooBig: return binarySearch(string: string, font: font, numberOfLines: numberOfLines, fitter: fitter, minSize: minSize, maxSize: fontSize, size: size, constraintSize: constraintSize)
        case .tooSmall: return binarySearch(string: string, font: font, numberOfLines: numberOfLines, fitter: fitter, minSize: fontSize, maxSize: maxSize, size: size, constraintSize: constraintSize)
        }
    }

    private static func singleLineSizeState(rectSize: CGSize, size: CGSize, fitter: CGFloat) -> FontSizeState {
        if rectSize.width >= size.width + fitter, rectSize.width <= size.width {
            .fit
        } else if rectSize.width > size.width {
            .tooBig
        } else {
            .tooSmall
        }
    }

    private static func multiLineSizeState(rectSize: CGSize, size: CGSize, fitter: CGFloat) -> FontSizeState {
        // if rect within 10 of size
        if rectSize.height < size.height + fitter &&
            rectSize.height > size.height - fitter &&
            rectSize.width > size.width + fitter &&
            rectSize.width < size.width - fitter
        {
            .fit
        } else if rectSize.height > size.height || rectSize.width > size.width {
            .tooBig
        } else {
            .tooSmall
        }
    }

    private enum FontSizeState {
        case fit
        case tooBig
        case tooSmall
    }
}
