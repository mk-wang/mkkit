//
//  Storage.swift
//
//
//  Created by MK on 2021/5/8.
//

import Foundation

// MARK: - KVStorage

public protocol KVStorage {
    func set(_ val: (NSCoding & NSObjectProtocol)?, for key: String)
    func object<T: AnyObject>(for key: String, of clz: T.Type) -> T?

    func object(for key: String) -> Any?

    func hasValue(_ key: String) -> Bool

    func set(_ val: Bool, for key: String)
    func bool(for key: String) -> Bool?

    func set(_ val: Int, for key: String)
    func int(for key: String) -> Int?

    func set(_ val: Int8, for key: String)
    func int8(for key: String) -> Int8?

    func set(_ val: Int16, for key: String)
    func int16(for key: String) -> Int16?

    func set(_ val: Int32, for key: String)
    func int32(for key: String) -> Int32?

    func set(_ val: Int64, for key: String)
    func int64(for key: String) -> Int64?

    func set(_ val: UInt, for key: String)
    func uint(for key: String) -> UInt?

    func set(_ val: UInt8, for key: String)
    func uint8(for key: String) -> UInt8?

    func set(_ val: UInt16, for key: String)
    func uint16(for key: String) -> UInt16?

    func set(_ val: UInt32, for key: String)
    func uint32(for key: String) -> UInt32?

    func set(_ val: UInt64, for key: String)
    func uint64(for key: String) -> UInt64?

    func set(_ val: Float, for key: String)
    func float(for key: String) -> Float?

    func set(_ val: Double, for key: String)
    func double(for key: String) -> Double?

    // MARK: - String

    func set(_ val: String, for key: String)
    func string(for key: String) -> String?

    // MARK: - Data

    func set(_ val: Data, for key: String)
    func data(for key: String) -> Data?

    // MARK: - Date

    func set(_ val: Date, for key: String)
    func date(for key: String) -> Date?

    // traver
    func dumpAll() -> [String: Any]

    // delete
    func remove(for key: String) -> Void

    func removeAll() -> Void
}

// MARK: - StorageMMKV
