//
//  Data.swift
//
//
//  Created by MK on 2021/6/4.
//

import CommonCrypto
import Foundation

public extension Data {
    static func toHex(buffer: [UInt8], lowerCase: Bool) -> String {
        let fmt = lowerCase ? "%02x" : "%02X"
        return buffer.map { String(format: fmt, $0) }.joined()
    }
}

public extension Data {
    var md5Buffer: [UInt8] {
        withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(count), &hash)
            return hash
        }
    }

    var md5: String {
        Self.toHex(buffer: md5Buffer, lowerCase: true)
    }

    var MD5: String {
        Self.toHex(buffer: md5Buffer, lowerCase: false)
    }
}

public extension Data {
    var sha256Buffer: [UInt8] {
        withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            CC_SHA256(bytes.baseAddress, CC_LONG(count), &hash)
            return hash
        }
    }

    var sha256: String {
        Self.toHex(buffer: sha256Buffer, lowerCase: true)
    }

    var SHA256: String {
        Self.toHex(buffer: sha256Buffer, lowerCase: false)
    }
}

public extension Data {
    func subdata(in range: CountableClosedRange<Data.Index>) -> Data {
        subdata(in: range.lowerBound ..< range.upperBound + 1)
    }

    var utf8Str: String? {
        String(data: self, encoding: .utf8)
    }

    var asciiStr: String? {
        String(data: self, encoding: .ascii)
    }
}

public extension Data {
    var jsonObject: Any? {
        try? JSONSerialization.jsonObject(with: self,
                                          options: .allowFragments)
    }
}

