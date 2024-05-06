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

    func setAssociatedObject(_ key: UnsafeRawPointer,
                             _ value: Any?,
                             _ policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    {
        objc_setAssociatedObject(self, key, value, policy)
    }

    func removeAssociatedObjects() {
        objc_removeAssociatedObjects(self)
    }

    func getOrMakeAssociatedObject<T>(
        _ key: UnsafeRawPointer,
        type _: T.Type,
        policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC,
        builder: ValueBuilder<T>
    ) -> T {
        if let value = objc_getAssociatedObject(self, key) as? T {
            return value
        }

        let value = builder()
        objc_setAssociatedObject(self, key, value, policy)
        return value
    }
}

public extension NSObject {
    var theClassName: String {
        NSStringFromClass(type(of: self))
    }
}
