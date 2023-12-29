//
//  StickyHeaderFlowLayout.swift
//  MKKit
//
//  Created by MK on 2023/12/29.
//

import UIKit

open class StickyHeaderFlowLayout: UICollectionViewFlowLayout {
    public var stickIndexPath: IndexPath = .init(row: 0, section: 0)

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        guard var layoutAttributes else {
            return layoutAttributes
        }

        if let attributes = layoutAttributes.first(where: { $0.indexPath == stickIndexPath }) {
            stick(attributes: attributes)
        } else if let attributes = layoutAttributesForItem(at: stickIndexPath) {
            stick(attributes: attributes)
            layoutAttributes.append(attributes)
        }

        return layoutAttributes
    }

    override open func shouldInvalidateLayout(forBoundsChange _: CGRect) -> Bool {
        true
    }

    private func stick(attributes: UICollectionViewLayoutAttributes) {
        guard let collectionView else {
            return
        }
        var frame = attributes.frame
        let top = collectionView.contentOffset.y + collectionView.contentInset.top
        frame.origin.y = max(top, frame.origin.y)
        attributes.frame = frame
        attributes.zIndex = 1
    }
}
