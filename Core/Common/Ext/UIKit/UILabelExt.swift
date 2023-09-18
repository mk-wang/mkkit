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
