//
//  IGListModelWrap.swift
//
//
//  Created by MK on 2022/5/24.
//

import Foundation
import IGListKit

// MARK: - IGModelWrap

open class IGModelWrap<T: NSObject>: ListDiffable {
    let object: T

    public init(object: T) {
        self.object = object
    }

    public func diffIdentifier() -> NSObjectProtocol {
        object
    }

    public func isEqual(toDiffableObject otherObject: ListDiffable?) -> Bool {
        guard let other = (otherObject as? Self)?.object else {
            return false
        }
        return object.isEqual(other)
    }
}

// MARK: - IGListModelWrap

open class IGListModelWrap<Element>: NSObject, ListDiffable {
    let list: [Element]

    public init(list: [Element]) {
        self.list = list
    }

    public func diffIdentifier() -> NSObjectProtocol {
        self
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        isEqual(object)
    }

    var isEmpty: Bool {
        list.isEmpty
    }

    var count: Int {
        list.count
    }

    func at(_ index: Int) -> Element? {
        list.at(index)
    }
}

// MARK: - IGBoxModel

protocol IGBoxModel: ListDiffable {
    var boxHeight: CGFloat {
        get
    }

    var boxColor: UIColor? {
        get
    }
}

// MARK: - IGBoxModelWrap

public class IGBoxModelWrap: IGBoxModel {
    let boxHeight: CGFloat
    let boxColor: UIColor?

    public func diffIdentifier() -> NSObjectProtocol {
        "IGBoxModelWrap \(boxHeight)" as NSString
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? Self else { return false }
        return other.boxHeight == boxHeight
    }

    init(boxHeight: CGFloat, boxColor: UIColor?) {
        self.boxHeight = boxHeight
        self.boxColor = boxColor
    }
}

extension IGBoxModelWrap {
    static func listController(configureBlock: ListSingleSectionCellConfigureBlock? = nil) -> ListSectionController {
        // for header view
        let sizeBlock: ListSingleSectionCellSizeBlock = { model, context in
            guard let model = model as? Self, let width = context?.containerSize.width else {
                return .zero
            }
            return CGSize(width: width, height: model.boxHeight)
        }

        let sectionController = ListSingleSectionController(cellClass: BoxCell.self,
                                                            configureBlock: {
                                                                model, cell in
                                                                cell.backgroundColor = (model as? Self)?.boxColor
                                                                configureBlock?(model, cell)
                                                            },
                                                            sizeBlock: sizeBlock)
        return sectionController
    }

    private class BoxCell: UICollectionViewCell {}
}
