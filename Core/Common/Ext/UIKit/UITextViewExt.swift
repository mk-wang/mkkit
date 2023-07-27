//
//  UITextViewExt.swift
//  MKKit
//
//  Created by MK on 2023/7/26.
//

import Foundation
import UIKit

public extension UITextView {
    func boundingFrame(ofTextRange range: Range<String.Index>?) -> CGRect? {
        guard let range else {
            return nil
        }
        let length = range.upperBound.encodedOffset - range.lowerBound.encodedOffset
        guard let start = position(from: beginningOfDocument,
                                   offset: range.lowerBound.encodedOffset),
            let end = position(from: start, offset: length),
            let txtRange = textRange(from: start, to: end)
        else {
            return nil
        }

        // we now have a UITextRange, so get the selection rects for that range
        let rects = selectionRects(for: txtRange)

        // init our return rect
        var returnRect = CGRect.zero

        // for each selection rectangle
        for thisSelRect in rects {
            // if it's the first one, just set the return rect
            if thisSelRect == rects.first {
                returnRect = thisSelRect.rect
            } else {
                // ignore selection rects with a width of Zero
                if thisSelRect.rect.size.width > 0 {
                    // we only care about the top (the minimum origin.y) and the
                    // sum of the heights
                    returnRect.origin.y = min(returnRect.origin.y, thisSelRect.rect.origin.y)
                    returnRect.size.height += thisSelRect.rect.size.height
                }
            }
        }
        return returnRect
    }
}
