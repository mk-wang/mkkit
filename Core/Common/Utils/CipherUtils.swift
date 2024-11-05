//
//  CipherUtils.swift
//  MKKit
//
//  Created by MK on 2023/8/28.
//

import CommonCrypto
import Foundation

// MARK: - CipherUtils

public enum CipherUtils {
    enum AESOperation {
        case encrypt
        case decrypt

        var ccOpt: CCOperation {
            switch self {
            case .encrypt:
                CCOperation(kCCEncrypt)
            case .decrypt:
                CCOperation(kCCDecrypt)
            }
        }
    }

    // MARK: - AESKeySize

    enum AESKeySize {
        case bits128
        case bits256

        var rawValue: Int {
            switch self {
            case .bits128:
                kCCKeySizeAES128
            case .bits256:
                kCCKeySizeAES256
            }
        }
    }

    static func aesOperation(data: Data, key: Data, iv: Data, keySize: AESKeySize, optration: AESOperation) -> Data? {
        let count = data.count
        let bufferSize = count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)

        var encryptedSize = 0

        let status = data.withUnsafeBytes { dataPtr in
            iv.withUnsafeBytes { ivPtr in
                key.withUnsafeBytes { keyPtr in
                    buffer.accessBytes { bufferPtr in
                        CCCrypt(optration.ccOpt,
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyPtr.baseAddress,
                                keySize.rawValue,
                                ivPtr.baseAddress,
                                dataPtr.baseAddress,
                                count,
                                bufferPtr.baseAddress,
                                bufferSize,
                                &encryptedSize)
                    }
                }
            }
        }

        guard status == kCCSuccess else {
            return nil
        }

        buffer.count = encryptedSize
        return buffer
    }

    public static func aes128Encrypt(data: Data, key: String, iv: String) -> Data? {
        guard let keyData = key.data(using: .utf8), let ivData = iv.data(using: .utf8) else {
            return nil
        }
        return aesOperation(data: data, key: keyData, iv: ivData, keySize: .bits128, optration: .encrypt)
    }

    public static func aes128Decrypt(data: Data, key: String, iv: String) -> Data? {
        guard let keyData = key.data(using: .utf8), let ivData = iv.data(using: .utf8) else {
            return nil
        }
        return aesOperation(data: data, key: keyData, iv: ivData, keySize: .bits128, optration: .decrypt)
    }
}

public extension Data {
    func aes128Encrypt(key: String, iv: String) -> Data? {
        CipherUtils.aes128Encrypt(data: self, key: key, iv: iv)
    }

    func aes128Decrypt(key: String, iv: String) -> Data? {
        CipherUtils.aes128Decrypt(data: self, key: key, iv: iv)
    }
}
