//
//  TagFlowLayout.swift
//
//
//  Created by MK on 2022/10/11.
//

import UIKit

// MARK: - TagFlowLayout

open class TagFlowLayout: UICollectionViewFlowLayout {
    var isRTL: Bool = false

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        guard let collectionView else {
            return attributes
        }

        if isRTL {
            var rightMargin = sectionInset.right
            var maxY: CGFloat = -1.0
            let inset = collectionView.contentInset
            let maxWidth = collectionView.bounds.width - inset.right - inset.left

            attributes?.forEach { layoutAttribute in
                var rect = layoutAttribute.frame
                if rect.origin.y >= maxY {
                    rightMargin = sectionInset.right
                }

                let size = layoutAttribute.frame.size
                rect.origin.x = maxWidth - size.width - rightMargin
                layoutAttribute.frame = rect

                rightMargin += size.width + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        } else {
            var leftMargin = sectionInset.left
            var maxY: CGFloat = -1.0
            attributes?.forEach { layoutAttribute in
                var rect = layoutAttribute.frame
                if rect.origin.y >= maxY {
                    leftMargin = sectionInset.left
                }

                rect.origin.x = leftMargin
                layoutAttribute.frame = rect

                leftMargin = layoutAttribute.frame.maxX + minimumInteritemSpacing
                maxY = max(layoutAttribute.frame.maxY, maxY)
            }
        }

        return attributes
    }

    override open var flipsHorizontallyInOppositeLayoutDirection: Bool {
        isRTL
    }
}
