//
//  Storage.swift
//
//
//  Created by MK on 2021/5/8.
//

import Foundation

// MARK: - KVStorage

public protocol KVStorage {
    func set(_ val: Any?, for key: String)
    func object(for key: String) -> Any?

    func hasValue(_ key: String) -> Bool

    func set(_ val: Bool, for key: String)
    func bool(for key: String) -> Bool?

    func set(_ val: Int8, for key: String)
    func int8(for key: String) -> Int8?

    func set(_ val: Int32, for key: String)
    func int32(for key: String) -> Int32?

    func set(_ val: Int64, for key: String)
    func int64(for key: String) -> Int64?

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

    func allKeys() -> [String]

    // delete
    func remove(for key: String) -> Void

    func removeAll() -> Void
}

// MARK: - StorageMMKV
