//
//  UnselectableTextView.swift
//  MKKit
//
//  Created by MK on 2023/10/25.
// https://stackoverflow.com/questions/36198299/uitextview-disable-selection-allow-links

import UIKit

open class UnselectableTextView: UITextView {
    override open func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        guard let pos = closestPosition(to: point) else {
            return false
        }

        guard let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left)) else {
            return false
        }

        let startIndex = offset(from: beginningOfDocument, to: range.start)

        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }
}
