//
//  Data.swift
//  YogaWorkout
//
//  Created by MK on 2021/6/4.
//

import CommonCrypto
import Foundation

public extension Data {
    var md5Buffer: [UInt8] {
        withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(count), &hash)
            return hash
        }
    }

    var md5: String {
        md5Buffer.map { String(format: "%02x", $0) }.joined()
    }

    var MD5: String {
        md5Buffer.map { String(format: "%02X", $0) }.joined()
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
        sha256Buffer.map { String(format: "%02x", $0) }.joined()
    }

    var SHA256: String {
        sha256Buffer.map { String(format: "%02X", $0) }.joined()
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
