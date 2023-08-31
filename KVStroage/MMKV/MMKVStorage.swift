//
//  MMKVStorage.swift
//  FastingCal
//
//  Created by MK on 2022/11/4.
//

import Foundation
import MMKV

// MARK: - MMKVStorage

open class MMKVStorage {
    private let storage: MMKV

    public init(storage: MMKV = MMKV.default()!) {
        self.storage = storage
    }

    public init(id: String, path: String?) {
        storage = MMKV(mmapID: id, relativePath: path)!
    }
}

// MARK: KVStorage

extension MMKVStorage: KVStorage {
    public func set(_ val: (NSCoding & NSObjectProtocol)?, for key: String) {
        storage.set(val, forKey: key)
    }

    public func object(for _: String) -> Any? {
        fatalError("object(for _: String) has not been implemented")
    }

    public func object<T>(for key: String, of type: T.Type) -> T? where T: AnyObject {
        guard let clz = type as? AnyClass, storage.contains(key: key) else {
            return nil
        }
        return storage.object(of: clz, forKey: key) as? T
    }

    public func dumpAll() -> [String: Any] {
        fatalError("dumpAll() has not been implemented")
    }

    public func removeAll() {
        storage.clearAll()
    }

    public func hasValue(_ key: String) -> Bool {
        storage.contains(key: key)
    }

    public func set(_ val: Bool, for key: String) {
        storage.set(val, forKey: key)
    }

    public func bool(for key: String) -> Bool? {
        storage.contains(key: key) ? storage.bool(forKey: key) : nil
    }

    // MARK: - Int

    public func set(_ val: Int, for key: String) {
        set(Int64(val), for: key)
    }

    public func int(for key: String) -> Int? {
        guard let val = int64(for: key) else {
            return nil
        }
        return Int(val)
    }

    public func set(_ val: Int8, for key: String) {
        set(Int32(val), for: key)
    }

    public func int8(for key: String) -> Int8? {
        guard let val = int32(for: key) else {
            return nil
        }
        return Int8(val)
    }

    public func set(_ val: Int16, for key: String) {
        set(Int32(val), for: key)
    }

    public func int16(for key: String) -> Int16? {
        guard let val = int32(for: key) else {
            return nil
        }
        return Int16(val)
    }

    public func set(_ val: Int32, for key: String) {
        storage.set(val, forKey: key)
    }

    public func int32(for key: String) -> Int32? {
        storage.contains(key: key) ? storage.int32(forKey: key) : nil
    }

    public func set(_ val: Int64, for key: String) {
        storage.set(val, forKey: key)
    }

    public func int64(for key: String) -> Int64? {
        storage.contains(key: key) ? storage.int64(forKey: key) : nil
    }

    public func set(_ val: UInt, for key: String) {
        set(UInt64(val), for: key)
    }

    public func uint(for key: String) -> UInt? {
        guard let val = uint64(for: key) else {
            return nil
        }
        return UInt(val)
    }

    public func set(_ val: UInt8, for key: String) {
        set(Int32(val), for: key)
    }

    public func uint8(for key: String) -> UInt8? {
        guard let val = int32(for: key) else {
            return nil
        }
        return UInt8(val)
    }

    public func set(_ val: UInt16, for key: String) {
        set(UInt32(val), for: key)
    }

    public func uint16(for key: String) -> UInt16? {
        guard let val = uint32(for: key) else {
            return nil
        }
        return UInt16(val)
    }

    public func set(_ val: UInt32, for key: String) {
        storage.set(val, forKey: key)
    }

    public func uint32(for key: String) -> UInt32? {
        storage.contains(key: key) ? storage.uint32(forKey: key) : nil
    }

    public func set(_ val: UInt64, for key: String) {
        storage.set(val, forKey: key)
    }

    public func uint64(for key: String) -> UInt64? {
        storage.contains(key: key) ? storage.uint64(forKey: key) : nil
    }

    // MARK: - Float & Double

    public func set(_ val: Float, for key: String) {
        storage.set(val, forKey: key)
    }

    public func float(for key: String) -> Float? {
        storage.contains(key: key) ? storage.float(forKey: key) : nil
    }

    public func set(_ val: Double, for key: String) {
        storage.set(val, forKey: key)
    }

    public func double(for key: String) -> Double? {
        storage.contains(key: key) ? storage.double(forKey: key) : nil
    }

    // MARK: - Object

    public func set(_ val: String, for key: String) {
        storage.set(val, forKey: key)
    }

    public func string(for key: String) -> String? {
        storage.string(forKey: key)
    }

    public func set(_ val: Data, for key: String) {
        storage.set(val, forKey: key)
    }

    public func data(for key: String) -> Data? {
        storage.data(forKey: key)
    }

    public func set(_ val: Date, for key: String) {
        storage.set(val, forKey: key)
    }

    public func date(for key: String) -> Date? {
        storage.date(forKey: key)
    }

    // MARK: - All Keys

    public func allKeys() -> [String] {
        (storage.allKeys() as? [String]) ?? []
    }

    // Delete
    public func remove(for key: String) {
        storage.removeValue(forKey: key)
    }

    public func close() {
        storage.close()
    }
}
