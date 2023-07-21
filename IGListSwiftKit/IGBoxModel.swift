//
//  IGListModelWrap.swift
//
//
//  Created by MK on 2022/5/24.
//

import Foundation
import IGListKit

// MARK: - IGBoxModel

protocol IGBoxModel: ListDiffable {
    var boxHeight: CGFloat {
        get
    }
}

// MARK: - IGBoxModelWrap

public class IGBoxModelWrap: IGBoxModel {
    let boxHeight: CGFloat

    public func diffIdentifier() -> NSObjectProtocol {
        NSNumber(value: boxHeight)
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? Self else { return false }
        return other.boxHeight == boxHeight
    }

    init(boxHeight: CGFloat) {
        self.boxHeight = boxHeight
    }
}

extension IGBoxModelWrap {
    static func listController(configureBlock: ListSingleSectionCellConfigureBlock? = nil) -> ListSectionController {
        let sizeBlock: ListSingleSectionCellSizeBlock = { model, context in
            guard let model = model as? Self, let width = context?.containerSize.width else {
                return .zero
            }
            return CGSize(width: width, height: model.boxHeight)
        }

        let sectionController = ListSingleSectionController(cellClass: BoxCell.self,
                                                            configureBlock: {
                                                                model, cell in
                                                                configureBlock?(model, cell)
                                                            },
                                                            sizeBlock: sizeBlock)
        return sectionController
    }

    private class BoxCell: UICollectionViewCell {}
}
