//
//  IGListModelWrap.swift
//
//
//  Created by MK on 2022/5/24.
//

import Foundation
import IGListKit

// MARK: - IGBoxModel

public class IGBoxModel: NSObject {
    let boxHeight: CGFloat
    public init(boxHeight: CGFloat) {
        self.boxHeight = boxHeight
    }
}

public extension IGBoxModel {
    static func listController(inset: UIEdgeInsets = .zero,
                               configureBlock: ListSingleSectionCellConfigureBlock? = nil) -> ListSectionController
    {
        let sizeBlock: ListSingleSectionCellSizeBlock = { model, context in
            guard let model = model as? Self, let width = context?.containerSize.width else {
                return .zero
            }
            return CGSize(width: width, height: model.boxHeight)
        }

        let sectionController = ListSingleSectionController(cellClass: UICollectionViewCell.self,
                                                            configureBlock: {
                                                                model, cell in
                                                                configureBlock?(model, cell)
                                                            },
                                                            sizeBlock: sizeBlock)
        sectionController.inset = inset
        return sectionController
    }
}
