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
    private var printers = [Printer]()

    public init() {}

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
            message: message,
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
            message: message,
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
            message: message,
            tag: tag,
            function: function,
            file: file,
            line: line)
    }

    public func log(level: Level,
                    message: () -> CustomStringConvertible,
                    tag: String?,
                    function: String,
                    file: String,
                    line: UInt)
    {
        guard level.rawValue >= Level.default.rawValue else {
            return
        }

        let printers = printers.isEmpty ? [Self.defaultLogger] : printers

        let value = message()
        let text = (value as? String) ?? value.description
        printers.forEach { $0.write(level: level, message: text, tag: tag, function: function, file: file, line: line) }
    }

    private static let defaultLogger = OSPrinter(subsystem: AppInfo.bundleIdentifier, category: "default")

    public enum Level: Int8 {
        case debug
        case info
        case error
    }
}

public extension Logger.Level {
    #if DEBUG_BUILD
        static var `default`: Self = .debug
    #else
        static var `default`: Self = .info
    #endif
}

extension Logger.Level {
    var osType: OSLogType {
        switch self {
        case .debug:
            .debug
        case .info:
            .info
        case .error:
            .error
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
    var tagInfo = ""
    if let tag, tag.isNotEmpty {
        tagInfo = ": \(tag)"
    }

    let langText = MKAppDelegate.shared?.findService(LangService.self)?.lang.rawValue ?? AppInfo.preferredLanguage!
//    return "[\(level)\(tagInfo)] \(function) \(message)"
    return "[\(langText) \(AppInfo.systemVersion) \(AppInfo.shortVersion)] [\(level)\(tagInfo)] \(file)#\(line) \(message)"
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
    private let inner: Printer

    public init(
        subsystem: String, category: String
    ) {
        if #available(iOS 14.0, *) {
            inner = OSPrinterNew(subsystem: subsystem, category: category)
        } else {
            inner = OSPrinterOld(subsystem: subsystem, category: category)
        }
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
        inner.write(level: level,
                    message: message,
                    tag: tag,
                    function: function,
                    file: file,
                    line: line)
    }
}

// MARK: - OSPrinterOld

class OSPrinterOld {
    private let osLog: OSLog

    public init(
        subsystem: String, category: String
    ) {
        osLog = .init(subsystem: subsystem, category: category)
    }
}

// MARK: Printer

extension OSPrinterOld: Printer {
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

// MARK: - OSPrinterNew

@available(iOS 14.0, *)
class OSPrinterNew {
    private let osLog: os.Logger
    public init(
        subsystem: String, category: String
    ) {
        osLog = .init(subsystem: subsystem, category: category)
    }
}

// MARK: Printer

@available(iOS 14.0, *)
extension OSPrinterNew: Printer {
    private static let dateFmt: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm:ss.SSS"
        return fmt
    }()

    private static var time: String {
        dateFmt.string(from: .init())
    }

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
        osLog.log(level: level.osLoggerLevel, "\(Self.time) \(content)")
    }
}

@available(iOS 14.0, *)
extension Logger.Level {
    var osLoggerLevel: OSLogType {
        switch self {
        case .debug:
            .debug
        case .info:
            .info
        case .error:
            .error
        }
    }
}

public extension Logger {
    static let shared: Logger = .init()
}
