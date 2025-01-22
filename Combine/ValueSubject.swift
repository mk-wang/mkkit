//
//  ValueSubject.swift
//  MKKit
//
//  Created by MK on 2023/5/10.
//

import Foundation

// MARK: - ValuePublisher

open class ValuePublisher<T: Any> {
    let retainOld: Bool
    // old , new
    private let subject: CurrentValueSubjectType<(T?, T), Never>
    open lazy var valuePublisher = subject.map(\.1).eraseToAnyPublisher()

    public fileprivate(set) var value: T {
        get {
            subject.value.1
        }
        set {
            let old = retainOld ? subject.value.1 : nil
            subject.value = (old, newValue)
        }
    }

    public lazy var valuesPublisher = subject.eraseToAnyPublisher()
    public var values: (T?, T) {
        subject.value
    }

    public init(_ value: T, retainOld: Bool = false) {
        self.retainOld = retainOld
        subject = CurrentValueSubjectType((nil, value))
    }
}

// MARK: - ValueSubject

open class ValueSubject<T: Any>: ValuePublisher<T> {
    override public var value: T {
        get {
            super.value
        }
        set {
            super.value = newValue
        }
    }
}
