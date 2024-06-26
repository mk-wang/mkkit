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

    func has(key: Key) -> Bool {
        index(forKey: key) != nil
    }

    func get(_ key: Key, default: Value) -> Value {
        self[key] ?? `default`
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
}
