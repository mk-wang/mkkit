//
//  IGSectionItem.swift
//  MKKit
//
//  Created by MK on 2023/7/31.
//

import Foundation
import IGListKit

// MARK: - IGSectionItem

open class IGSectionItem: NSObject {
    public fileprivate(set) var cachedSize: CGSize? = nil

    open func clearCache() {
        cachedSize = nil
    }
}

// MARK: - IGSectionItemController

open class IGSectionItemController<Item: IGSectionItem, Cell: UICollectionViewCell>: ListSectionController {
    open var item: Item?
    public let cellType: Cell.Type

    open var sizeBlock: ((ListCollectionContext, Item) -> CGSize)?
    open var heightBlock: ((ListCollectionContext, Item, CGFloat) -> CGFloat)?

    open var configureBlock: ((Item, Cell) -> Void)?
    open var onClick: VoidFunction?

    public init(cellType: Cell.Type = Cell.self) {
        self.cellType = cellType
    }

    override open func didUpdate(to object: Any) {
        item = object as? Item
    }

    override open func sizeForItem(at _: Int) -> CGSize {
        guard let collectionContext, let item else {
            return .zero
        }

        if let size = item.cachedSize {
            return size
        }

        if let sizeBlock {
            let size = sizeBlock(collectionContext, item)
            item.cachedSize = size
            return size
        }
        if let heightBlock {
            let width = collectionContext.containerSize.width - inset.horizontalSize
            let size = CGSize(width, heightBlock(collectionContext, item, width))
            item.cachedSize = size
            return size
        }
        return .zero
    }

    override open func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let item, let cell = collectionContext?.dequeueReusableCell(of: cellType,
                                                                          for: self,
                                                                          at: index) as? Cell
        else {
            return UICollectionViewCell()
        }
        configureBlock?(item, cell)
        return cell
    }

    override open func didSelectItem(at _: Int) {
        onClick?()
    }
}
