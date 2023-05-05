//
//  ValueSubject.swift
//  MKKit
//
//  Created by MK on 2023/5/10.
//

import Foundation
import OpenCombine

open class ValueSubject<T: Any> {
    // old , value
    private let subject: CurrentValueSubject<(T?, T), Never>

    open lazy var valuePublisher = subject.map(\.1).eraseToAnyPublisher()
    open var value: T {
        get {
            subject.value.1
        }
        set {
            let old = subject.value.0
            subject.value = (old, newValue)
        }
    }

    open lazy var valuesPublisher = subject.eraseToAnyPublisher()
    open var values: (T?, T) {
        subject.value
    }

    public init(_ value: T) {
        subject = CurrentValueSubject((nil, value))
    }
}
