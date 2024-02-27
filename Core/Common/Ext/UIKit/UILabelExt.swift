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
