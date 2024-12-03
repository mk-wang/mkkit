//
//  WeakReference.swift
//  MKKit
//
//  Created by MK on 2023/8/28.
//

import Foundation

// MARK: - WeakReference

open class WeakReference {
    public private(set) weak var reference: AnyObject?

    public init(reference: AnyObject) {
        self.reference = reference
    }
}

// MARK: - OCWeakReference

open class OCWeakReference<T: AnyObject>: NSObject {
    public private(set) weak var reference: T?

    public init(reference: T) {
        self.reference = reference
    }
}

// MARK: - OCValue

open class OCValue: NSObject {
    private let value: Any

    public init(value: Any) {
        self.value = value
        super.init()
    }

    open func get<T>() -> T? {
        value as? T
    }
}
