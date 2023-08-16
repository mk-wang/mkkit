//
//  UnFairLock.swift
//  MKKit
//
//  Created by MK on 2023/7/19.
//

import Foundation

// MARK: - UnFairLock

open class UnFairLock {
    private let inner: os_unfair_lock_t

    public init() {
        inner = os_unfair_lock_t.allocate(capacity: 1)
        inner.initialize(to: .init())
    }
}

// MARK: NSLocking

extension UnFairLock: NSLocking {
    public func lock() {
        os_unfair_lock_lock(inner)
    }

    public func unlock() {
        os_unfair_lock_unlock(inner)
    }
}

public extension UnFairLock {
    func run(_ block: VoidFunction) {
        defer {
            unlock()
        }
        lock()
        block()
    }
}
