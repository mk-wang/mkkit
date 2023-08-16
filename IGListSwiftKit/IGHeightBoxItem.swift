//
//  IGHeightBoxItem.swift
//
//
//  Created by MK on 2022/5/24.
//

import Foundation
import IGListKit

// MARK: - IGHeightBoxItem

open class IGHeightBoxItem: IGSectionItem {
    let boxHeight: CGFloat
    public init(boxHeight: CGFloat) {
        self.boxHeight = boxHeight
    }
}

public extension IGHeightBoxItem {
    static func igController<Item: IGHeightBoxItem, Cell: UICollectionViewCell>(
        configureBlock: ((Item, Cell) -> Void)? = nil
    ) -> ListSectionController {
        let ctr = IGSectionItemController<Item, Cell>()
        ctr.heightBlock = { _, item, _ in
            item.boxHeight
        }
        ctr.configureBlock = configureBlock
        return ctr
    }
}
