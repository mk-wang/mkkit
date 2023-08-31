//
//  KVStorageExt.swift
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

public class KVStorageBuilder {
    public let builder: () -> KVStorage?
    public let keyBuilder: ((String) -> String)?

    public init(builder: @escaping () -> KVStorage?, keyBuilder: ((String) -> String)? = nil) {
        self.builder = builder
        self.keyBuilder = keyBuilder
    }

    private var storage: KVStorage? {
        builder()
    }

    private func fixedKey(_ text: String) -> String {
        keyBuilder?(text) ?? text
    }
}

// MARK: KVStorage

extension KVStorageBuilder: KVStorage {
    public func set(_ val: Date, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: Data, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: String, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: Double, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: Float, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: UInt64, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: UInt32, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: UInt16, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: UInt8, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: UInt, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: Int64, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: Int32, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: Int16, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: Int8, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: Int, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: Bool, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func set(_ val: (NSCoding & NSObjectProtocol)?, for key: String) {
        storage?.set(val, for: fixedKey(key))
    }

    public func object<T>(for key: String, of clz: T.Type) -> T? where T: AnyObject {
        storage?.object(for: fixedKey(key), of: clz)
    }

    public func object(for key: String) -> Any? {
        storage?.object(for: fixedKey(key))
    }

    public func hasValue(_ key: String) -> Bool {
        storage?.hasValue(fixedKey(key)) ?? false
    }

    public func bool(for key: String) -> Bool? {
        storage?.bool(for: fixedKey(key))
    }

    public func int(for key: String) -> Int? {
        storage?.int(for: fixedKey(key))
    }

    public func int8(for key: String) -> Int8? {
        storage?.int8(for: fixedKey(key))
    }

    public func int16(for key: String) -> Int16? {
        storage?.int16(for: fixedKey(key))
    }

    public func int32(for key: String) -> Int32? {
        storage?.int32(for: fixedKey(key))
    }

    public func int64(for key: String) -> Int64? {
        storage?.int64(for: fixedKey(key))
    }

    public func uint(for key: String) -> UInt? {
        storage?.uint(for: fixedKey(key))
    }

    public func uint8(for key: String) -> UInt8? {
        storage?.uint8(for: fixedKey(key))
    }

    public func uint16(for key: String) -> UInt16? {
        storage?.uint16(for: fixedKey(key))
    }

    public func uint32(for key: String) -> UInt32? {
        storage?.uint32(for: fixedKey(key))
    }

    public func uint64(for key: String) -> UInt64? {
        storage?.uint64(for: fixedKey(key))
    }

    public func float(for key: String) -> Float? {
        storage?.float(for: fixedKey(key))
    }

    public func double(for key: String) -> Double? {
        storage?.double(for: fixedKey(key))
    }

    public func string(for key: String) -> String? {
        storage?.string(for: fixedKey(key))
    }

    public func data(for key: String) -> Data? {
        storage?.data(for: fixedKey(key))
    }

    public func date(for key: String) -> Date? {
        storage?.date(for: fixedKey(key))
    }

    public func dumpAll() -> [String: Any] {
        storage?.dumpAll() ?? [:]
    }

    public func remove(for key: String) {
        storage?.remove(for: key)
    }

    public func removeAll() {
        storage?.removeAll()
    }

    public func close() {
        storage?.close()
    }
}
