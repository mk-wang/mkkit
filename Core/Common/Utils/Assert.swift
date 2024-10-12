//
//  Assert.swift
//  Pods
//
//  Created by MK on 2024/10/12.
//

import CoreFoundation

@inline(__always)
public func ensureMain() {
    if !Thread.isMainThread {
        fatalError("should run on main thread ")
    }
}
