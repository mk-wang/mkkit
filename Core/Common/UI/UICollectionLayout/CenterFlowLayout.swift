//
//  CenterFlowLayout.swift
//  MKKit
//
//  Created by MK on 2023/10/10

import Foundation
import UIKit

// MARK: - CenterCellCollectionViewFlowLayout

open class CenterFlowLayout: UICollectionViewFlowLayout {
    public var dragBegin: CGPoint?
    public var velocityThreashHold: CGFloat = 0.3
    public var dragDistanceThreashHold: CGFloat = 20
    public var fastToIngoreDistance: CGFloat = 0.5

    open func centerFor(_ proposedOffsetPoint: CGPoint,
                        velocity velocityPoint: CGPoint) -> CGPoint?
    {
        guard let collectionView else {
            return nil
        }

        let proposedOffset = pointValue(proposedOffsetPoint)
        let contentOffset = pointValue(collectionView.contentOffset)
        let velocity = pointValue(velocityPoint)

        Logger.shared.debug("proposed \(proposedOffset) contentOffset \(contentOffset) velocity \(velocity)")

        if let dragBegin, abs(velocity) < fastToIngoreDistance {
            let dragDistance = contentOffset - pointValue(dragBegin)

            if abs(dragDistance) < dragDistanceThreashHold {
                Logger.shared.debug("by distance \(dragDistance)")
                return dragBegin
            }
        }

        let bounds = collectionView.bounds
        guard let centerList = layoutAttributesForElements(in: bounds)?
            .compactMap({ [unowned(unsafe) self] in
                $0.representedElementCategory == .cell ? pointValue($0.center) : nil
            }), !centerList.isEmpty
        else {
            return nil
        }

        var best: CGFloat?

        if abs(velocity) > velocityThreashHold {
            Logger.shared.debug("by content offset")
            let forward = velocity > 0
            let list = centerList.sorted(by: { [unowned(unsafe) self] in
                forward == ($0 < $1)
            })
            best = list.at(1)
        } else {
            Logger.shared.debug("by proposedOffset")

            let listCenter = sizeValue(bounds.size) * 0.5 + proposedOffset

            do {
                var bestDistance: CGFloat = .greatestFiniteMagnitude
                for center in centerList {
                    let distance = abs(center - listCenter)
                    if bestDistance > distance {
                        bestDistance = distance
                        best = center
                    }
                }
            }
        }

        guard let best else {
            return nil
        }

        let offset = best - sizeValue(bounds.size) * 0.5
        let cross = pointCrossValue(proposedOffsetPoint)

        return makePoint(value: offset, cross: cross)
    }

    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                           withScrollingVelocity velocity: CGPoint) -> CGPoint
    {
        let point = centerFor(proposedContentOffset, velocity: velocity)

        guard let point else {
            Logger.shared.debug("by super")
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset,
                                             withScrollingVelocity: velocity)
        }
        return point
    }
}
