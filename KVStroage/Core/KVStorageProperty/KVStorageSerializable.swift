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

    static func write(storage: KVStorage, value: KVValue, key: String)
    static func read(storage: KVStorage, key: String) -> KVValue?

    /// The value to store in `UserDefaults`.
    var kvValue: KVValue { get }

    /// Initializes the object using the provided value.
    ///
    /// - Parameter kvValue: The previously store value fetched from `UserDefaults`.
    init(kvValue: KVValue)
}

///// :nodoc:
public extension KVStorageSerializable where Self: RawRepresentable, Self.RawValue: KVStorageSerializable {
    var kvValue: RawValue.KVValue { rawValue.kvValue }

    init(kvValue: RawValue.KVValue) {
        self = Self(rawValue: Self.RawValue(kvValue: kvValue))!
    }
}

extension KVStorage {
    func saveSerializable<T: KVStorageSerializable>(_ value: T, for key: String) {
        T.write(storage: self, value: value.kvValue, key: key)
    }

    func getSerializable<T: KVStorageSerializable>(for key: String) -> T? {
        let value = T.read(storage: self, key: key)

        guard let value else {
            return nil
        }

        return T(kvValue: value)
    }
}

// MARK: - Bool + KVStorageSerializable

/// :nodoc:
extension Bool: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.bool(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Int + KVStorageSerializable

extension Int: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.int(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Int8 + KVStorageSerializable

/// :nodoc:
extension Int8: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.int8(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Int16 + KVStorageSerializable

extension Int16: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.int16(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Int32 + KVStorageSerializable

extension Int32: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.int32(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Int64 + KVStorageSerializable

extension Int64: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.int64(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - UInt + KVStorageSerializable

extension UInt: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.uint(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - UInt8 + KVStorageSerializable

/// :nodoc:
extension UInt8: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.uint8(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - UInt16 + KVStorageSerializable

/// :nodoc:
extension UInt16: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.uint16(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - UInt32 + KVStorageSerializable

extension UInt32: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.uint32(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - UInt64 + KVStorageSerializable

/// :nodoc:
extension UInt64: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.uint64(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Float + KVStorageSerializable

/// :nodoc:
extension Float: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.float(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Double + KVStorageSerializable

/// :nodoc:
extension Double: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.double(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - String + KVStorageSerializable

/// :nodoc:
extension String: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.string(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - URL + KVStorageSerializable

/// :nodoc:
extension URL: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.url(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Date + KVStorageSerializable

/// :nodoc:
extension Date: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.date(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Data + KVStorageSerializable

/// :nodoc:
extension Data: KVStorageSerializable {
    public static func write(storage: KVStorage, value: Self, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> Self? {
        storage.data(for: key)
    }

    public var kvValue: Self { self }

    public init(kvValue: Self) {
        self = kvValue
    }
}

// MARK: - Array + KVStorageSerializable

/// :nodoc:
extension Array: KVStorageSerializable where Element: KVStorageSerializable {
    public static func write(storage: KVStorage, value: [Element.KVValue], key: String) {
        if let object = value as? (NSCoding & NSObjectProtocol) {
            storage.set(object, for: key)
        }
    }

    public static func read(storage: KVStorage, key: String) -> [Element.KVValue]? {
        storage.object(for: key, of: NSArray.self) as? [Element.KVValue]
    }

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
    public static func write(storage: KVStorage, value: [Element.KVValue], key: String) {
        if let object = value as? (NSCoding & NSObjectProtocol) {
            storage.set(object, for: key)
        }
    }

    public static func read(storage: KVStorage, key: String) -> [Element.KVValue]? {
        storage.object(for: key, of: NSArray.self) as? [Element.KVValue]
    }

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
    public static func write(storage: KVStorage, value: [String: Value.KVValue], key: String) {
        if let object = value as? (NSCoding & NSObjectProtocol) {
            storage.set(object, for: key)
        }
    }

    public static func read(storage: KVStorage, key: String) -> [String: Value.KVValue]? {
        storage.object(for: key, of: NSDictionary.self) as? [String: Value.KVValue]
    }

    public var kvValue: [String: Value.KVValue] {
        mapValues { $0.kvValue }
    }

    public init(kvValue: [String: Value.KVValue]) {
        self = kvValue.mapValues { Value(kvValue: $0) }
    }
}
