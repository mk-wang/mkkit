//
//  Logger.swift
//
//
//  Created by MK on 2022/3/17.
//

import Foundation
import os.log

// MARK: - Logger

open class Logger {
    var level: Level = .default

    let category: String
    private var printers = [Printer]()

    public init(category: String) {
        self.category = category
    }

    public func add(printer: Printer) {
        printers.append(printer)
    }

    public func debug(_ message: @autoclosure () -> CustomStringConvertible,
                      tag: String? = nil,
                      function: String = #function,
                      file: String = #file,
                      line: UInt = #line)
    {
        log(level: .debug,
            message: message().description,
            tag: tag,
            function: function,
            file: file,
            line: line)
    }

    public func info(_ message: @autoclosure () -> CustomStringConvertible,
                     tag: String? = nil,
                     function: String = #function,
                     file: String = #file,
                     line: UInt = #line)
    {
        log(level: .info,
            message: message().description,
            tag: tag,
            function: function,
            file: file,
            line: line)
    }

    public func error(_ message: @autoclosure () -> CustomStringConvertible,
                      tag: String? = nil,
                      function: String = #function,
                      file: String = #file,
                      line: UInt = #line)
    {
        log(level: .error,
            message: message().description,
            tag: tag,
            function: function,
            file: file,
            line: line)
    }

    public func log(level: Level,
                    message: String,
                    tag: String?,
                    function: String,
                    file: String,
                    line: UInt)
    {
        guard level.rawValue >= Level.default.rawValue else {
            return
        }

        printers.forEach { $0.write(level: level, message: message, tag: tag, function: function, file: file, line: line) }
    }

    public enum Level: Int8 {
        case debug
        case info
        case error
    }
}

extension Logger.Level {
    #if DEBUG
        static let `default`: Self = .debug
    #else
        static let `default`: Self = .info
    #endif
}

extension Logger.Level {
    var osType: OSLogType {
        switch self {
        case .debug:
            return .debug
        case .info:
            return .info
        case .error:
            return .error
        }
    }
}

public func shortFileName(_ file: String) -> String {
    URL(fileURLWithPath: file).lastPathComponent
}

public func formatMessage(level: Logger.Level,
                          message: String,
                          tag: String?,
                          function _: String,
                          file: String,
                          line: UInt) -> String
{
    let file = shortFileName(file)
    let tagInfo = tag == nil || tag!.isEmpty ? "" : ": \(tag!)"
//    return "[\(level)\(tagInfo)] \(function) \(message)"
    return "[\(level)\(tagInfo)] \(file)#\(line) \(message)"
}

// MARK: - Printer

public protocol Printer {
    func write(level: Logger.Level,
               message: String,
               tag: String?,
               function: String,
               file: String,
               line: UInt)
}

// MARK: - OSPrinter

open class OSPrinter {
    private let osLog: OSLog

    public init(
        subsystem: String, category: String
    ) {
        osLog = OSLog(subsystem: subsystem, category: category)
    }
}

// MARK: Printer

extension OSPrinter: Printer {
    public func write(level: Logger.Level,
                      message: String,
                      tag: String?,
                      function: String,
                      file: String,
                      line: UInt)
    {
        let content = formatMessage(level: level,
                                    message: message,
                                    tag: tag,
                                    function: function,
                                    file: file,
                                    line: line)
        os_log("%{public}@", log: osLog, type: level.osType, content)
    }
}
