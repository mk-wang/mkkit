//
//  UILabelExt.swift
//
//
//  Created by MK on 2021/5/24.
//

import UIKit

public extension UILabel {
    convenience init(text: String?) {
        self.init()
        self.text = text
    }

    convenience init(text: String, font: UIFont) {
        self.init()
        self.text = text
        self.font = font
    }
}

public extension UILabel {
    var requiredHeight: CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.attributedText = attributedText
        label.sizeToFit()
        return label.frame.height
    }

    var visibleLines: Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize,
                                         options: .usesLineFragmentOrigin,
                                         attributes: [NSAttributedString.Key.font: font], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height / charSize))
        return linesRoundedUp
    }

    func highlight(searchedText: String?, color: UIColor) {
        guard let txtLabel = text, let searchedText else {
            return
        }

        let attributeTxt = NSMutableAttributedString(string: txtLabel)
        let range: NSRange = attributeTxt.mutableString.range(of: searchedText, options: .caseInsensitive)

        attributeTxt.addAttribute(NSAttributedString.Key.backgroundColor, value: color, range: range)

        attributedText = attributeTxt
    }

    func lineToFit(_ lines: Int = 1) {
        numberOfLines = lines
        adjustsFontSizeToFitWidth = true
    }

    var hasText: Bool {
        text?.isNotEmpty ?? false
    }
}

// from https://raw.githubusercontent.com/tbaranes/FittableFontLabel/master/Source/UILabelExtension.swift
public extension UILabel {
    /**
     Resize the font to make the current text fit the label frame.
     - parameter maxFontSize:  The max font size available
     - parameter minFontScale: The min font scale that the font will have
     - parameter rectSize:     Rect size where the label must fit
     */
    func fontSizeToFit(fitter: CGFloat, maxFontSize: CGFloat = 100, minFontScale: CGFloat = 0.1, rectSize: CGSize? = nil) {
        guard let text else {
            return
        }

        let newFontSize = text.fontSizeThatFits(font: font,
                                                numberOfLines: numberOfLines,
                                                rectSize: rectSize ?? bounds.size,
                                                fitter: fitter,
                                                maxFontSize: maxFontSize,
                                                minFontScale: minFontScale)
        font = font.withSize(newFontSize)
    }
}

// MARK: - Search

extension String {
    private enum FontSizeState {
        case fit
        case tooBig
        case tooSmall
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
        return (calculatedFontSize * 10.0).rounded(.down) / 10.0
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
//        attributes[NSAttributedString.Key.font] = font.withSize(fontSize)
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
            return .fit
        } else if rectSize.width > size.width {
            return .tooBig
        } else {
            return .tooSmall
        }
    }

    private static func multiLineSizeState(rectSize: CGSize, size: CGSize, fitter: CGFloat) -> FontSizeState {
        // if rect within 10 of size
        if rectSize.height < size.height + fitter &&
            rectSize.height > size.height - fitter &&
            rectSize.width > size.width + fitter &&
            rectSize.width < size.width - fitter
        {
            return .fit
        } else if rectSize.height > size.height || rectSize.width > size.width {
            return .tooBig
        } else {
            return .tooSmall
        }
    }
}
