//
//  NSObject+IGList.swift
//  MKKit
//
//  Created by MK on 2023/7/20.
//

import Foundation
import IGListKit

// MARK: - NSObject + ListDiffable

extension NSObject: ListDiffable {
    open func diffIdentifier() -> NSObjectProtocol {
        self
    }

    open func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        isEqual(object)
    }
}

public extension NSObject {
    static let emptyDiffableList: [NSObject] = []
}

//
//// MARK: - IGSectionSectionControllerMake
//
// public protocol IGSectionSectionControllerMake {
//    func igContoller(for: ListDiffable) -> ListSectionController?
// }
