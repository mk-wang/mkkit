//
//  UserDefaultsStorage.swift
//  ConnectSDK
//
//  Created by MK on 2022/11/10.
//

import Foundation

// MARK: - UserDefaultsStorage

open class UserDefaultsStorage {
    private let storage: UserDefaults

    public init(storage: UserDefaults = .standard) {
        self.storage = storage
    }
}

// MARK: KVStorage

extension UserDefaultsStorage: KVStorage {
    public func hasValue(_ key: String) -> Bool {
        storage.object(forKey: key) != nil
    }

    public func set(_ val: (NSCoding & NSObjectProtocol)?, for key: String) {
        storage.set(val, forKey: key)
    }

    public func object(for key: String) -> Any? {
        storage.object(forKey: key)
    }

    public func object<T>(for key: String, of _: T.Type) -> T? where T: AnyObject {
        storage.object(forKey: key) as? T
    }

    public func set(_ val: Date, for key: String) {
        storage.set(val, forKey: key)
    }

    public func set(_ val: Data, for key: String) {
        storage.set(val, forKey: key)
    }

    public func set(_ val: String, for key: String) {
        storage.set(val, forKey: key)
    }

    public func set(_ val: Double, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: Float, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: Int, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: Int8, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: Int16, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: Int32, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: Int64, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: UInt, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: UInt8, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: UInt16, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: UInt32, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: UInt64, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: Bool, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func bool(for key: String) -> Bool? {
        (storage.object(forKey: key) as? NSNumber)?.boolValue
    }

    public func int(for key: String) -> Int? {
        (storage.object(forKey: key) as? NSNumber)?.intValue
    }

    public func int8(for key: String) -> Int8? {
        (storage.object(forKey: key) as? NSNumber)?.int8Value
    }

    public func int16(for key: String) -> Int16? {
        (storage.object(forKey: key) as? NSNumber)?.int16Value
    }

    public func int32(for key: String) -> Int32? {
        (storage.object(forKey: key) as? NSNumber)?.int32Value
    }

    public func int64(for key: String) -> Int64? {
        (storage.object(forKey: key) as? NSNumber)?.int64Value
    }

    public func uint(for key: String) -> UInt? {
        (storage.object(forKey: key) as? NSNumber)?.uintValue
    }

    public func uint8(for key: String) -> UInt8? {
        (storage.object(forKey: key) as? NSNumber)?.uint8Value
    }

    public func uint16(for key: String) -> UInt16? {
        (storage.object(forKey: key) as? NSNumber)?.uint16Value
    }

    public func uint32(for key: String) -> UInt32? {
        (storage.object(forKey: key) as? NSNumber)?.uint32Value
    }

    public func uint64(for key: String) -> UInt64? {
        (storage.object(forKey: key) as? NSNumber)?.uint64Value
    }

    public func float(for key: String) -> Float? {
        (storage.object(forKey: key) as? NSNumber)?.floatValue
    }

    public func double(for key: String) -> Double? {
        (storage.object(forKey: key) as? NSNumber)?.doubleValue
    }

    public func string(for key: String) -> String? {
        storage.object(forKey: key) as? String
    }

    public func data(for key: String) -> Data? {
        storage.object(forKey: key) as? Data
    }

    public func date(for key: String) -> Date? {
        storage.object(forKey: key) as? Date
    }

    public func dumpAll() -> [String: Any] {
        storage.dictionaryRepresentation()
    }

    public func remove(for key: String) {
        storage.removeObject(forKey: key)
    }

    public func removeAll() {
        guard let domain = Bundle.main.bundleIdentifier else {
            return
        }
        storage.removePersistentDomain(forName: domain)
    }
}
