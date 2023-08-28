//
//  WeakReference.swift
//  MKKit
//
//  Created by MK on 2023/8/28.
//

import Foundation

open class WeakReference {
    public private(set) weak var reference: AnyObject?

    public init(reference: AnyObject) {
        self.reference = reference
    }
}
