//
//  PreferenceManagerSetting.swift
//
//
//  Created by MK on 2021/8/11.
//

import Foundation

extension KVStorage {
    func get(for key: String, default defaultValue: Bool) -> Bool {
        bool(for: key) ?? defaultValue
    }

    func get(for key: String, default defaultValue: Int8) -> Int8 {
        int8(for: key) ?? defaultValue
    }

    func get(for key: String, default defaultValue: Int64) -> Int64 {
        int64(for: key) ?? defaultValue
    }

    func get(for key: String, default defaultValue: UInt64) -> UInt64 {
        uint64(for: key) ?? defaultValue
    }

    func get(for key: String, default defaultValue: Double) -> Double {
        double(for: key) ?? defaultValue
    }

    func set(_ val: URL, for key: String) {
        set(val.absoluteString, for: key)
    }

    func url(for key: String) -> URL? {
        guard let text = string(for: key) else {
            return nil
        }
        return URL(string: text)
    }
}

// MARK: - KVStorageBuilder

public struct KVStorageBuilder {
    public let builder: () -> KVStorage
    public init(builder: @escaping () -> KVStorage) {
        self.builder = builder
    }

    private var storage: KVStorage {
        builder()
    }
}

// MARK: KVStorage

extension KVStorageBuilder: KVStorage {
    public func set(_ val: Date, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: Data, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: String, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: Double, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: Float, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: UInt64, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: UInt32, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: UInt16, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: UInt8, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: UInt, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: Int64, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: Int32, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: Int16, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: Int8, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: Int, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: Bool, for key: String) {
        storage.set(val, for: key)
    }

    public func set(_ val: (NSCoding & NSObjectProtocol)?, for key: String) {
        storage.set(val, for: key)
    }

    public func object<T>(for key: String, of clz: T.Type) -> T? where T: AnyObject {
        storage.object(for: key, of: clz)
    }

    public func object(for key: String) -> Any? {
        storage.object(for: key)
    }

    public func hasValue(_ key: String) -> Bool {
        storage.hasValue(key)
    }

    public func bool(for key: String) -> Bool? {
        storage.bool(for: key)
    }

    public func int(for key: String) -> Int? {
        storage.int(for: key)
    }

    public func int8(for key: String) -> Int8? {
        storage.int8(for: key)
    }

    public func int16(for key: String) -> Int16? {
        storage.int16(for: key)
    }

    public func int32(for key: String) -> Int32? {
        storage.int32(for: key)
    }

    public func int64(for key: String) -> Int64? {
        storage.int64(for: key)
    }

    public func uint(for key: String) -> UInt? {
        storage.uint(for: key)
    }

    public func uint8(for key: String) -> UInt8? {
        storage.uint8(for: key)
    }

    public func uint16(for key: String) -> UInt16? {
        storage.uint16(for: key)
    }

    public func uint32(for key: String) -> UInt32? {
        storage.uint32(for: key)
    }

    public func uint64(for key: String) -> UInt64? {
        storage.uint64(for: key)
    }

    public func float(for key: String) -> Float? {
        storage.float(for: key)
    }

    public func double(for key: String) -> Double? {
        storage.double(for: key)
    }

    public func string(for key: String) -> String? {
        storage.string(for: key)
    }

    public func data(for key: String) -> Data? {
        storage.data(for: key)
    }

    public func date(for key: String) -> Date? {
        storage.date(for: key)
    }

    public func dumpAll() -> [String: Any] {
        storage.dumpAll()
    }

    public func remove(for key: String) {
        storage.remove(for: key)
    }

    public func removeAll() {
        storage.removeAll()
    }
}
