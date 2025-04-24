//
//  VerticalAlignmentLabel.swift
//  MKKit
//
//  Created by MK on 2024/2/7.
//

import Foundation
import UIKit

// MARK: - VerticalAlignmentLabel

public class VerticalAlignmentLabel: UILabel {
    public var verticalTextAlignment: VerticalTextAlignment = .top {
        didSet {
            setNeedsDisplay()
        }
    }

    override public func drawText(in rect: CGRect) {
        let actualRect = textRect(forBounds: rect, limitedToNumberOfLines: numberOfLines)
        super.drawText(in: actualRect)
    }

    override public func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch verticalTextAlignment {
        case .top:
            textRect.origin.y = bounds.origin.y
        case .bottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) * 0.5
        }
        return textRect
    }

    public enum VerticalTextAlignment {
        case top
        case center
        case bottom
    }
}
