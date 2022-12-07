//
//  KVStorageSerializable.swift
//  MKKit
//
//  Created by MK on 2022/12/7.
//

import Foundation

// MARK: - KVStorageSerializable

public protocol KVStorageSerializable {
    /// The type of the value that is stored in `UserDefaults`.
    associatedtype KVValue

    /// The value to store in `UserDefaults`.
    var kvValue: KVValue { get }

    /// Initializes the object using the provided value.
    ///
    /// - Parameter kvValue: The previously store value fetched from `UserDefaults`.
    init(kvValue: KVValue)
}

extension KVStorage {
    func saveSerializable(_ value: some KVStorageSerializable, for key: String) {
        set(value.kvValue, for: key)
    }

    func getSerializable<T: KVStorageSerializable>(for key: String) -> T? {
        let obj = object(for: key)

        guard let value = obj as? T.KVValue else {
            return nil
        }

        return T(kvValue: value)
    }
}

// MARK: - Bool + KVStorageSerializable

/// :nodoc:
extension Bool: KVStorageSerializable {
    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Int + KVStorageSerializable

/// :nodoc:
extension Int: KVStorageSerializable {
    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - UInt + KVStorageSerializable

/// :nodoc:
extension UInt: KVStorageSerializable {
    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - UInt64 + KVStorageSerializable

/// :nodoc:
extension UInt64: KVStorageSerializable {
    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Float + KVStorageSerializable

/// :nodoc:
extension Float: KVStorageSerializable {
    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Double + KVStorageSerializable

/// :nodoc:
extension Double: KVStorageSerializable {
    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - String + KVStorageSerializable

/// :nodoc:
extension String: KVStorageSerializable {
    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - URL + KVStorageSerializable

/// :nodoc:
extension URL: KVStorageSerializable {
    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Date + KVStorageSerializable

/// :nodoc:
extension Date: KVStorageSerializable {
    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Data + KVStorageSerializable

/// :nodoc:
extension Data: KVStorageSerializable {
    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Array + KVStorageSerializable

/// :nodoc:
extension Array: KVStorageSerializable where Element: KVStorageSerializable {
    public var kvValue: [Element.KVValue] {
        map(\.kvValue)
    }

    public init(kvValue: [Element.KVValue]) {
        self = kvValue.map { Element(kvValue: $0) }
    }
}

// MARK: - Set + KVStorageSerializable

/// :nodoc:
extension Set: KVStorageSerializable where Element: KVStorageSerializable {
    public var kvValue: [Element.KVValue] {
        map(\.kvValue)
    }

    public init(kvValue: [Element.KVValue]) {
        self = Set(kvValue.map { Element(kvValue: $0) })
    }
}

// MARK: - Dictionary + KVStorageSerializable

/// :nodoc:
extension Dictionary: KVStorageSerializable where Key == String, Value: KVStorageSerializable {
    public var kvValue: [String: Value.KVValue] {
        mapValues { $0.kvValue }
    }

    public init(kvValue: [String: Value.KVValue]) {
        self = kvValue.mapValues { Value(kvValue: $0) }
    }
}

/// :nodoc:
public extension KVStorageSerializable where Self: RawRepresentable, Self.RawValue: KVStorageSerializable {
    var kvValue: RawValue.KVValue { rawValue.kvValue }

    init(kvValue: RawValue.KVValue) {
        self = Self(rawValue: Self.RawValue(kvValue: kvValue))!
    }
}
