//
//  ss.swift
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
    public func set(_ val: Any?, for key: String) {
        storage.set(val, forKey: key)
    }

    public func object(for key: String) -> Any? {
        storage.object(forKey: key)
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

    public func set(_ val: UInt64, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: Int64, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: Int32, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func set(_ val: Int8, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func hasValue(_ key: String) -> Bool {
        storage.object(forKey: key) != nil
    }

    public func set(_ val: Bool, for key: String) {
        storage.set(NSNumber(value: val), forKey: key)
    }

    public func bool(for key: String) -> Bool? {
        guard let val = storage.object(forKey: key) as? NSNumber else {
            return nil
        }

        return val.boolValue
    }

    public func int8(for key: String) -> Int8? {
        guard let val = storage.object(forKey: key) as? NSNumber else {
            return nil
        }

        return val.int8Value
    }

    public func int32(for key: String) -> Int32? {
        guard let val = storage.object(forKey: key) as? NSNumber else {
            return nil
        }

        return val.int32Value
    }

    public func int64(for key: String) -> Int64? {
        guard let val = storage.object(forKey: key) as? NSNumber else {
            return nil
        }

        return val.int64Value
    }

    public func uint64(for key: String) -> UInt64? {
        guard let val = storage.object(forKey: key) as? NSNumber else {
            return nil
        }

        return val.uint64Value
    }

    public func float(for key: String) -> Float? {
        guard let val = storage.object(forKey: key) as? NSNumber else {
            return nil
        }

        return val.floatValue
    }

    public func double(for key: String) -> Double? {
        guard let val = storage.object(forKey: key) as? NSNumber else {
            return nil
        }

        return val.doubleValue
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
