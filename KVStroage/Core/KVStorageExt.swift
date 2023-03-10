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
}
