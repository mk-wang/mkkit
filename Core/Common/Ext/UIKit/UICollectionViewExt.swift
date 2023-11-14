//
//  UICollectionViewExt.swift
//
//
//  Created by MK on 2022/6/12.
//

import UIKit

public extension UICollectionView {
    func reloadWithoutAnimation() {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        reloadData()
        CATransaction.commit()
    }

    func reloadDataWithCompletion(_ completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                if let cb = completion {
                    cb()
                }
                return
            }

            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            CATransaction.setCompletionBlock(completion)
            self.reloadData()
            CATransaction.commit()
        }
    }

    func frame(of section: Int) -> CGRect {
        var frame: CGRect = .null

        for item in 0 ..< numberOfItems(inSection: section) {
            let indexPath = IndexPath(item: item, section: section)

            if let attributes = collectionViewLayout.layoutAttributesForItem(at: indexPath) {
                let rect = attributes.frame
                frame = rect.union(frame)
            }
        }

        return frame
    }
}

public extension UICollectionView {
    func selectAll(animated: Bool) {
        (0 ..< numberOfSections).compactMap { section -> [IndexPath]? in
            (0 ..< numberOfItems(inSection: section)).compactMap { item -> IndexPath? in
                IndexPath(item: item, section: section)
            }
        }.flatMap { $0 }.forEach { indexPath in
            selectItem(at: indexPath, animated: animated, scrollPosition: [])
        }
    }

    /// Deselects all selected cells.
    func deselectAll(animated: Bool) {
        indexPathsForSelectedItems?.forEach { indexPath in
            deselectItem(at: indexPath, animated: animated)
        }
    }
}
