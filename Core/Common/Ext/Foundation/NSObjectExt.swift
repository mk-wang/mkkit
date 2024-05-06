//
//  NSObjectExt.swift
//
//
//  Created by MK on 2021/5/27.
//

import Foundation

// MARK: - NSObject

public extension NSObject {
    func getAssociatedObject(_ key: UnsafeRawPointer) -> Any? {
        objc_getAssociatedObject(self, key)
    }

    func setAssociatedObject(_ key: UnsafeRawPointer, _ value: Any?, _ policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        objc_setAssociatedObject(self, key, value, policy)
    }

    var theClassName: String {
        NSStringFromClass(type(of: self))
    }
}
