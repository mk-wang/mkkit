//
//  CollectionExt.swift
//  MKKit
//
//  Created by MK on 2023/3/17.
//

import Foundation

public extension RangeReplaceableCollection where Element: Equatable {
    @discardableResult
    mutating func appendIfAbsent(_ element: Element) -> (appended: Bool, memberAfterAppend: Element) {
        if let index = firstIndex(of: element) {
            return (false, self[index])
        } else {
            append(element)
            return (true, element)
        }
    }
}

public extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }
}
