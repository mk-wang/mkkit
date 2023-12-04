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

// MARK: - MKCountable

public protocol MKCountable {
    var count: Int {
        get
    }
}

// MARK: - NSArray + MKCountable

extension NSArray: MKCountable {}

// MARK: - NSDictionary + MKCountable

extension NSDictionary: MKCountable {}

// MARK: - NSData + MKCountable

extension NSData: MKCountable {}

// MARK: - NSString + MKCountable

extension NSString: MKCountable {
    public var count: Int {
        length
    }
}

// MARK: - NSAttributedString + MKCountable

extension NSAttributedString: MKCountable {
    public var count: Int {
        length
    }
}

public extension MKCountable {
    var isEmpty: Bool {
        count == 0
    }

    var isNotEmpty: Bool {
        !isEmpty
    }
}
