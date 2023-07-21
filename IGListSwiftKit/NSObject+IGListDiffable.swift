//
//  NSObject+IGListDiffable.swift
//  MKKit
//
//  Created by MK on 2023/7/20.
//

import Foundation
import IGListKit

// MARK: - NSObject + ListDiffable

extension NSObject: ListDiffable {
    public func diffIdentifier() -> NSObjectProtocol {
        self
    }

    public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        isEqual(object)
    }
}
