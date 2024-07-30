//
//  DictionaryExt.swift
//  MKKit
//
//  Created by MK on 2023/2/15.
//

import Foundation

public extension Dictionary {
    /// Merges the dictionary with dictionaries passed. The latter dictionaries will override
    /// values of the keys that are already set
    ///
    /// - parameter dictionaries: A comma seperated list of dictionaries
    mutating func merge(dictionaries: [Key: Value]...) {
        for dict in dictionaries {
            for (key, value) in dict {
                updateValue(value as! Value, forKey: key as! Key)
            }
        }
    }

    mutating func get(_ key: Key, putIfAbsent: Bool, builder: () -> Value) -> Value {
        var value = self[key]

        if value == nil {
            value = builder()
            if putIfAbsent {
                self[key] = value!
            }
        }

        return value!
    }

    @inlinable func map<K: Hashable, V>(_ transform: (Key, Value) throws -> (K, V)) rethrows -> [K: V] {
        var dict: [K: V] = [:]
        for (k, v) in self {
            let rt = try transform(k, v)
            dict[rt.0] = rt.1
        }
        return dict
    }

    @inlinable func has(key: Key) -> Bool {
        index(forKey: key) != nil
    }

    @inlinable func get(_ key: Key, default: Value) -> Value {
        self[key] ?? `default`
    }
}
