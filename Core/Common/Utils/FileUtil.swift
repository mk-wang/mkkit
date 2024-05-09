//
//  FileUtil.swift
//  MKKit
//
//  Created by MK on 2022/11/29.
//

import CommonCrypto
import Foundation

// MARK: - FileUtil

public enum FileUtil {
    static var fileManager = FileManager.default
    #if targetEnvironment(simulator)
        public static var homeDir: URL?
    #endif
}

public extension FileUtil {
    static var documentDirectory: URL {
        #if targetEnvironment(simulator)
            if let homeDir, fileManager.fileExists(atPath: homeDir.path) {
                let url = homeDir.appendingPathComponent("document")
                try? createDir(url: url, deleteIfNotDir: true)
                return url
            }
        #endif
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    static var libraryDirectory: URL {
        #if targetEnvironment(simulator)
            if let homeDir, fileManager.fileExists(atPath: homeDir.path) {
                let url = homeDir.appendingPathComponent("library")
                try? createDir(url: url, deleteIfNotDir: true)
                return url
            }
        #endif
        return fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
    }

    static var temporaryDirectory: URL {
        #if targetEnvironment(simulator)
            if let homeDir, fileManager.fileExists(atPath: homeDir.path) {
                let url = homeDir.appendingPathComponent("temp")
                try? createDir(url: url, deleteIfNotDir: true)
                return url
            }
        #endif
        return fileManager.temporaryDirectory
    }
}

public extension FileUtil {
    static func copyFile(source: URL, target: URL) -> Bool {
        guard let input = InputStream(url: source),
              let output = OutputStream(url: target, append: false)
        else {
            return false
        }

        input.open()
        output.open()

        defer {
            input.close()
            output.close()
        }

        let chunkSize = 1024
        var buffer = [UInt8](repeating: 0, count: chunkSize)

        var bytesRead = input.read(&buffer, maxLength: chunkSize)
        while bytesRead > 0 {
            let bytesWritten = output.write(buffer, maxLength: bytesRead)
            if bytesWritten != bytesRead {
                return false
            }
            bytesRead = input.read(&buffer, maxLength: chunkSize)
        }
        return true
    }
}

public extension FileUtil {
    static func bundlePath(components: [String]) -> String {
        let bundlePath = Bundle.main.bundlePath
        let mStr = NSMutableString(string: bundlePath)
        for comp in components {
            mStr.appendFormat("/%@", comp)
        }
        return mStr as String
    }

    static func createDir(url: URL, deleteIfNotDir: Bool = false) throws {
        var (isExists, isDir) = try fileExists(url: url)

        if isExists, !isDir, deleteIfNotDir {
            try fileManager.removeItem(at: url)
            isExists = false
        }

        if !isExists {
            try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    static func move(source: URL, dest: URL) throws {
        let dirUrl = dest.deletingLastPathComponent()
        try createDir(url: dirUrl, deleteIfNotDir: true)
        try fileManager.moveItem(at: source, to: dest)
    }

    static func remove(url: URL) throws {
        try fileManager.removeItem(at: url)
    }

    static func loadFiles(url: URL) throws -> [String] {
        try fileManager.contentsOfDirectory(atPath: url.path)
    }

    static func makeTempURL(ext: String? = nil) -> URL {
        var file = UUID().uuidString
        if let ext {
            file += ".\(ext)"
        }
        return temporaryDirectory.appendingPathComponent(file)
    }
}

public extension FileUtil {
    static func fileExists(url: URL) throws -> (Bool, Bool) {
        var isDir: ObjCBool = false
        let rt = fileManager.fileExists(atPath: url.path, isDirectory: &isDir)
        return (rt, isDir.boolValue)
    }

    static func containsFile(dir: URL, file: URL) -> Bool {
        let ptr = UnsafeMutablePointer<FileManager.URLRelationship>.allocate(capacity: 1)

        defer {
            ptr.deallocate()
        }

        do {
            try fileManager.getRelationship(ptr, ofDirectoryAt: dir, toItemAt: file)
            return ptr.pointee == .contains
        } catch {
            return false
        }
    }

    static func containsFileFast(dir: URL, file: URL) -> Bool {
        let p1 = dir.path.privatePrefixRemovedStr
        let p2 = file.path.privatePrefixRemovedStr
        return p2.starts(with: p1)
    }

    // 标准化，试着移除 /private（有时候不起作用）
    static func standardizedURL(url: URL) -> URL {
        if url.isFileURL {
            (url as NSURL).standardizingPath!
        } else {
            url.standardized
        }
    }

    static func isEqualURL(_ u1: URL, _ u2: URL) -> Bool {
        guard let p1 = (u1 as NSURL).standardizingPath?.path,
              let p2 = (u2 as NSURL).standardizingPath?.path
        else {
            return false
        }
        return isEqualPath(p1, p2)
    }

    static func isEqualPath(_ p1: String, _ p2: String) -> Bool {
        if p1 == p2 {
            return true
        }

        let x1 = removePrivatePrefix(p1)
        let x2 = removePrivatePrefix(p2)

        return x1 == x2
    }

    static func removePrivatePrefix(_ str: String) -> String {
        guard str.hasPrefix("/private") else {
            return str
        }
        let startIndex = str.index(str.startIndex, offsetBy: 8)
        let subString = str[startIndex ..< str.endIndex]
        return String(subString)
    }
}

public extension String {
    var privatePrefixRemovedStr: String {
        FileUtil.removePrivatePrefix(self)
    }
}

public extension FileUtil {
    static func freeDiskSpaceInBytes() -> UInt64 {
        let dir = NSHomeDirectory()
        guard let attrs = try? fileManager.attributesOfFileSystem(forPath: dir),
              let totalDiskSpaceInBytes = attrs[FileAttributeKey.systemFreeSize] as? UInt64
        else {
            return 0
        }
        return totalDiskSpaceInBytes
    }
}

public extension FileUtil {
    static func md5(path: String) -> String? {
        let bufferSize = 4096

        guard let stream = InputStream(fileAtPath: path) else {
            return nil
        }

        var context = CC_MD5_CTX()
        CC_MD5_Init(&context)

        stream.open()
        defer {
            stream.close()
        }

        var buffer = [UInt8](repeating: 0, count: bufferSize)

        while stream.hasBytesAvailable {
            let read = stream.read(&buffer, maxLength: bufferSize)
            if read > 0 {
                CC_MD5_Update(&context, buffer, CC_LONG(read))
            } else if read == 0 {
                break
            } else {
                return nil
            }
        }

        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Final(&digest, &context)

        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
