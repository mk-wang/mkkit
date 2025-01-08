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
    static let homeDirectory: URL = resolvedFileURL(NSHomeDirectory().fileURL)

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
        do {
            try createDir(url: dirUrl, deleteIfNotDir: true)
            try fileManager.moveItem(at: source, to: dest)
        } catch {
            Logger.shared.error("Failed to move file from \(source) to \(dest): \(error)")
            throw error
        }
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

    static func resolvedFilePath(_ fileURL: URL) -> String {
        let resolvedPath = fileURL.resolvingSymlinksInPath().path
        if resolvedPath == fileURL.path {
            do {
                return try fileManager.destinationOfSymbolicLink(atPath: resolvedPath)
            } catch {
                Logger.shared.error("Failed to resolve symbolic link for \(fileURL.path): \(error)")
            }
        }
        return fileURL.standardizingFilePath
    }

    static func resolvedFileURL(_ fileURL: URL) -> URL {
        resolvedFilePath(fileURL).fileURL
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
        let p1 = dir.standardizingFilePath
        let p2 = file.standardizingFilePath
        return p2.starts(with: p1)
    }

    static func isEqualURL(_ u1: URL, _ u2: URL) -> Bool {
        u1.standardizingFilePath == u2.standardizingFilePath
    }

    static func removePrivatePrefix(_ str: String) -> String {
        for prefixText in ["/private", "file:///private/"] {
            if str.hasPrefix(prefixText) {
                let startIndex = str.index(str.startIndex, offsetBy: prefixText.count)
                let subString = str[startIndex ..< str.endIndex]
                return .init(subString)
            }
        }
        return str
    }
}

public extension FileUtil {
    static func isFileInAppSandbox(fileURL: URL) -> Bool {
        containsFile(dir: homeDirectory, file: fileURL)
    }

    static func isFileInAppSandboxFast(fileURL: URL) -> Bool {
        containsFileFast(dir: homeDirectory, file: fileURL)
    }
}

public extension FileUtil {
    static func fileAttributes(at url: URL) -> [FileAttributeKey: Any]? {
        try? fileManager.attributesOfItem(atPath: url.path)
    }

    static func folderSize(at url: URL) -> UInt64 {
        let files = (try? fileManager.subpathsOfDirectory(atPath: url.path)) ?? []
        return files.reduce(0) { size, file in
            let filePath = url.appendingPathComponent(file).path
            let attributes = try? fileManager.attributesOfItem(atPath: filePath)
            return size + (attributes?[.size] as? UInt64 ?? 0)
        }
    }
}

public extension URL {
    var standardizingFilePath: String {
        guard isFileURL,
              let url = (self as? NSURL)?.standardizingPath
        else {
            return standardized.path
        }

        return FileUtil.removePrivatePrefix(url.path)
    }

    var resolvedFileURL: URL {
        FileUtil.resolvedFileURL(self)
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
