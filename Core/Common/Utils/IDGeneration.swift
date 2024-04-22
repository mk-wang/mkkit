//
//  IDGeneration.swift
//  MKKit
//
//  Created by MK on 2024/4/22.
//

import Foundation

// MARK: - IDGeneration

open class IDGeneration<T> {
    private let lock: NSLocking?

    private var current: T
    private let valueBuilder: ValueBuilder1<T, T>

    public init(defaultIdBuilder: ValueBuilder<T>,
                lockBuilder: ValueBuilder<NSLocking?>? = nil,
                idBuilder: @escaping ValueBuilder1<T, T>)
    {
        self.current = defaultIdBuilder()
        self.lock = lockBuilder?()
        self.valueBuilder = idBuilder
    }

    open func generate() -> T {
        lock?.lock()
        defer {
            lock?.unlock()
        }

        current = valueBuilder(current)
        return current
    }
}

// MARK: - IntIDGeneration

open class IntIDGeneration: IDGeneration<Int> {
    public init(lockBuilder: ValueBuilder<NSLocking?>? = nil) {
        super.init(defaultIdBuilder: { 0 }, lockBuilder: lockBuilder, idBuilder: { $0 + 1 })
    }
}

// MARK: - UIntIDGeneration

open class UIntIDGeneration: IDGeneration<UInt> {
    public init(lockBuilder: ValueBuilder<NSLocking?>? = nil) {
        super.init(defaultIdBuilder: { 0 }, lockBuilder: lockBuilder, idBuilder: { $0 + 1 })
    }
}
