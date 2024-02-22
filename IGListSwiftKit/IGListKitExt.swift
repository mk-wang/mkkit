//
//  IGListKitExt.swift
//  MKKit
//
//  Created by MK on 2024/2/19.
//

import Foundation
import IGListKit

public extension ListSectionController {
    func batchUpdate(animated: Bool = true, updates: @escaping VoidFunction2<ListSectionController, ListBatchContext>) {
        collectionContext?.performBatch(animated: animated,
                                        updates: { [weak self] in
                                            guard let self else {
                                                return
                                            }
                                            updates(self, $0)
                                        })
    }

    func reload(animated: Bool = true) {
        batchUpdate(animated: animated) {
            $1.reload($0)
        }
    }
}
