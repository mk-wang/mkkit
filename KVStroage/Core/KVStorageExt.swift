//
//  PreferenceManagerSetting.swift
//  YogaWorkout
//
//  Created by MK on 2021/8/11.
//

import Foundation

// Data
extension KVStorage {
    func set(_ val: Encodable, for key: String) {
        if let data = try? JSONEncoder().encode(val) {
            set(data, for: key)
        }
    }

    func object<T: Decodable>(for key: String) -> T? {
        guard let data = data(for: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

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
