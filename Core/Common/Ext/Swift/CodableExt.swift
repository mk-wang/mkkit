//
//  Codable.swift
//
//
//  Created by MK on 2022/6/2.
//

import Foundation

public extension Encodable {
    var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }

    var jsonString: String? {
        jsonData?.utf8Str
    }
}

public extension String {
    func decodeJson<T: Decodable>() throws -> T? {
        guard let data = utf8Data else {
            return nil
        }
        return try data.decodeJson()
    }

    func decodeJson<T: Decodable>(_ t: T.Type) throws -> T? {
        guard let data = utf8Data else {
            return nil
        }
        return try data.decodeJson(t)
    }

    func decodeJson<T: Decodable>(defalut: T) -> T {
        guard let data = utf8Data else {
            return defalut
        }
        return (try? data.decodeJson()) ?? defalut
    }
}

public extension Data {
    func decodeJson<T: Decodable>() throws -> T {
        try JSONDecoder().decode(T.self, from: self)
    }

    func decodeJson<T: Decodable>(_: T.Type) throws -> T {
        try JSONDecoder().decode(T.self, from: self)
    }
}
