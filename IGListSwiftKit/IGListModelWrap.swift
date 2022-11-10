//
//  IGListModelWrap.swift
//
//
//  Created by MK on 2022/5/24.
//

import Foundation
import IGListKit

// MARK: - IGListModelWrap

class IGListModelWrap<Element>: NSObject, ListDiffable {
    let list: [Element]

    init(list: [Element]) {
        self.list = list
    }

    func diffIdentifier() -> NSObjectProtocol {
        self
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
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

// MARK: - IGHeightModelWrap

class IGHeightModelWrap: ListDiffable {
    func diffIdentifier() -> NSObjectProtocol {
        "IGHeightModelWrap \(height)" as NSString
    }

    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? Self else { return false }
        return other.height == height
    }

    let height: CGFloat

    init(height: CGFloat) {
        self.height = height
    }
}

extension IGHeightModelWrap {
    static func listController(configureBlock: ListSingleSectionCellConfigureBlock? = nil) -> ListSectionController {
        // for header view
        let sizeBlock: ListSingleSectionCellSizeBlock = { model, context in
            guard let model = model as? Self else {
                return .zero
            }
            return CGSize(width: (context?.containerSize.width)!, height: model.height)
        }

        let sectionController = ListSingleSectionController(cellClass: Cell.self,
                                                            configureBlock: configureBlock ?? {
                                                                _, _ in
                                                            },
                                                            sizeBlock: sizeBlock)
        return sectionController
    }

    private class Cell: UICollectionViewCell {}
}
