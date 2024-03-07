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
    open var onClick: (() -> Void)?

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

// MARK: - IGSectionListItem

open class IGSectionListItem<T>: NSObject {
    public fileprivate(set) var cachedSize: [Int: CGSize] = [:]
    public let items: [T]

    public init(items: [T]) {
        self.items = items
    }

    open func clearCache() {
        cachedSize.removeAll()
    }
}

// MARK: - IGSectionItemListController

open class IGSectionItemListController<T, Item: IGSectionListItem<T>, Cell: UICollectionViewCell>: ListSectionController {
    open var item: Item?
    public let cellType: Cell.Type

    open var sizeBlock: ((ListCollectionContext, Int, T) -> CGSize)?
    open var heightBlock: ((ListCollectionContext, Int, T, CGFloat) -> CGFloat)?

    open var configureBlock: ((Int, T, Cell) -> Void)?
    open var onClick: ((Int, T) -> Void)?
    open var reuseIdentifierBuilder: ((Int, T) -> String)?

    public init(cellType: Cell.Type = Cell.self) {
        self.cellType = cellType
    }

    override open func didUpdate(to object: Any) {
        item = object as? Item
    }

    override open func numberOfItems() -> Int {
        item?.items.count ?? 0
    }

    override open func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext, let item, let value = item.items.at(index) else {
            return .zero
        }

        if let size = item.cachedSize[index] {
            return size
        }

        if let sizeBlock {
            let size = sizeBlock(collectionContext, index, value)
            item.cachedSize[index] = size
            return size
        }

        if let heightBlock {
            let width = collectionContext.containerSize.width - inset.horizontalSize
            let size = CGSize(width, heightBlock(collectionContext, index, value, width))
            item.cachedSize[index] = size
            return size
        }

        return .zero
    }

    override open func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let value = item?.items.at(index),
              let cell = collectionContext?.dequeueReusableCell(of: cellType,
                                                                withReuseIdentifier: reuseIdentifierBuilder?(index, value),
                                                                for: self,
                                                                at: index) as? Cell
        else {
            return .init()
        }

        configureBlock?(index, value, cell)
        return cell
    }

    override open func didSelectItem(at index: Int) {
        guard let onClick, let value = item?.items.at(index) else {
            return
        }
        onClick(index, value)
    }
}
