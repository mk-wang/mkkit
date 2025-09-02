//
//  Logger+DDPrinter.swift
//  MKKit
//
//  Created by MK on 2024/4/1.
//

import CocoaLumberjack
import Foundation
import SSZipArchive

public extension Logger {
    static let ddLogger = DDPrinter()

    func zipLogsData() -> Data? {
        guard let url = Self.ddLogger.zipLogs() else {
            return nil
        }
        return try? Data(contentsOf: url, options: .mappedIfSafe)
    }
}

// MARK: - DDPrinter

public class DDPrinter {
    public let fileLogger = DDFileLogger() // File Logger

    public init() {
        fileLogger.rollingFrequency = 60 * 60 * 24 * 15 // 15 days
        fileLogger.maximumFileSize = 1024 * 1024 * 2 // 2M
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger, with: .info)
    }
}

public extension DDPrinter {
    func zipLogs() -> URL? {
        let files = fileLogger.logFileManager.sortedLogFilePaths
        guard !files.isEmpty else {
            return nil
        }
        let tmp = FileUtil.makeTempURL(ext: ".zip")
        SSZipArchive.createZipFile(atPath: tmp.path, withFilesAtPaths: files)
        return tmp
    }
}

// MARK: Printer

extension DDPrinter: Printer {
    public func write(level: Logger.Level, message: String, tag: String?, function: String, file: String, line: UInt) {
        let content = formatMessage(level: level,
                                    message: message,
                                    tag: tag,
                                    function: function,
                                    file: file,
                                    line: line)
        let format: DDLogMessageFormat = .init(stringLiteral: content)
        if level == .info {
            DispatchQueue.global(qos: .background).async {
                DDLogInfo(format, level: .info)
            }
        } else if level == .error {
            DispatchQueue.global(qos: .background).async {
                DDLogError(format, level: .error)
            }
        } else if level == .debug {
            DispatchQueue.global(qos: .background).async {
                DDLogDebug(format, level: .debug)
            }
        }
    }
}
