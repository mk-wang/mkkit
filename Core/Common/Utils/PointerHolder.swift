//
//  PointerHolder.swift
//
//
//  Created by MK on 2022/9/2.
//

import Foundation

class PointerHolder<T> {
    let ptr: UnsafeMutablePointer<T>

    #if DEBUG
        let idf = UUID().uuidString
    #endif

    init(capacity: Int) {
        ptr = UnsafeMutablePointer<T>.allocate(capacity: capacity)
    }

    deinit {
        ptr.deallocate()
    }
}
