//
//  PagingCollectionViewLayout.swift
//  MKKit
//
//  Created by MK on 2023/10/10. 不是很好用
//  https://raw.githubusercontent.com/akxo/paging-collection-view-layout/master/PagingCollectionViewLayout.swift
// https://gist.github.com/vinhnx/fb20c6942b5823df1c35e69850caf9f6

import Foundation
import UIKit

// MARK: - CenterCellCollectionViewFlowLayout

open class CenterCellCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var mostRecentOffset: CGPoint = .init()

    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        if velocity.x == 0 {
            return mostRecentOffset
        }

        if let cv = collectionView {
            let cvBounds = cv.bounds
            let halfWidth = cvBounds.size.width * 0.5

            if let attributesForVisibleCells = layoutAttributesForElements(in: cvBounds) {
                var candidateAttributes: UICollectionViewLayoutAttributes?
                for attributes in attributesForVisibleCells {
                    // == Skip comparison with non-cell items (headers and footers) == //
                    if attributes.representedElementCategory != UICollectionView.ElementCategory.cell {
                        continue
                    }

                    if (attributes.center.x == 0) || (attributes.center.x > (cv.contentOffset.x + halfWidth) && velocity.x < 0) {
                        continue
                    }
                    candidateAttributes = attributes
                }

                // Beautification step , I don't know why it works!
                if proposedContentOffset.x == -(cv.contentInset.left) {
                    return proposedContentOffset
                }

                guard let _ = candidateAttributes else {
                    return mostRecentOffset
                }
                mostRecentOffset = CGPoint(x: floor(candidateAttributes!.center.x - halfWidth), y: proposedContentOffset.y)
                return mostRecentOffset
            }
        }

        // fallback
        mostRecentOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        return mostRecentOffset
    }
}

// MARK: - PagingCollectionViewLayout

open class PagingCollectionViewLayout: UICollectionViewFlowLayout {
    var velocityThresholdPerPage: CGFloat = 2
    var numberOfItemsPerPage: CGFloat = 1

    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                           withScrollingVelocity velocity: CGPoint) -> CGPoint
    {
        guard let collectionView else { return proposedContentOffset }

        let pageLength: CGFloat
        let approxPage: CGFloat
        let currentPage: CGFloat
        let speed: CGFloat

        if scrollDirection == .horizontal {
            pageLength = (itemSize.width + minimumLineSpacing) * numberOfItemsPerPage
            approxPage = collectionView.contentOffset.x / pageLength
            speed = velocity.x
        } else {
            pageLength = (itemSize.height + minimumLineSpacing) * numberOfItemsPerPage
            approxPage = collectionView.contentOffset.y / pageLength
            speed = velocity.y
        }

        if speed < 0 {
            currentPage = ceil(approxPage)
        } else if speed > 0 {
            currentPage = floor(approxPage)
        } else {
            currentPage = round(approxPage)
        }

        guard speed != 0 else {
            if scrollDirection == .horizontal {
                return CGPoint(x: currentPage * pageLength, y: 0)
            } else {
                return CGPoint(x: 0, y: currentPage * pageLength)
            }
        }

        var nextPage: CGFloat = currentPage + (speed > 0 ? 1 : -1)

        let increment = speed / velocityThresholdPerPage
        nextPage += (speed < 0) ? ceil(increment) : floor(increment)

        if scrollDirection == .horizontal {
            return CGPoint(x: nextPage * pageLength, y: 0)
        } else {
            return CGPoint(x: 0, y: nextPage * pageLength)
        }
    }
}
