//
//  SemaphoreLock.swift
//  MKKit
//
//  Created by MK on 2023/8/28.
//

import Foundation

// MARK: - SemaphoreLock

open class SemaphoreLock {
    let semaphore: DispatchSemaphore

    public init(value: Int = 1) {
        semaphore = .init(value: value)
    }
}

// MARK: NSLocking

extension SemaphoreLock: NSLocking {
    public func lock() {
        semaphore.wait()
    }

    public func unlock() {
        semaphore.signal()
    }
}
