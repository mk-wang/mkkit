//
//  NSObjectExt.swift
//
//
//  Created by MK on 2021/5/27.
//

import Foundation

// MARK: - AssociatedProperty

public protocol AssociatedProperty: NSObjectProtocol {
    func getAssociatedObject(_ key: UnsafeRawPointer) -> Any?

    func setAssociatedObject(_ key: UnsafeRawPointer, _ value: Any?, _ policy: objc_AssociationPolicy)
}

public extension AssociatedProperty {
    func getAssociatedObject(_ key: UnsafeRawPointer) -> Any? {
        guard let value = objc_getAssociatedObject(self, key) else {
            return nil
        }
        return value
    }

    func setAssociatedObject(_ key: UnsafeRawPointer, _ value: Any?, _ policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        objc_setAssociatedObject(self, key, value, policy)
    }
}

public extension NSObject {
    var theClassName: String {
        NSStringFromClass(type(of: self))
    }
}

// MARK: - NSObject + AssociatedProperty

extension NSObject: AssociatedProperty {}
