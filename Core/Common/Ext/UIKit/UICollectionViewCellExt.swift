//
//  UICollectionViewCellExt.swift
//  MKKit
//
//  Created by MK on 2023/7/21.
//

import Foundation
import UIKit

public extension UICollectionViewCell {}

// MARK: - HighlightCollectionViewCell

open class HighlightCollectionViewCell: UICollectionViewCell {
    override open var isHighlighted: Bool {
        didSet {
            handleHighlightState(highLighted: isHighlighted)
        }
    }
}
