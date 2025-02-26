//
//  Logger+WSPrinter.swift
//  MKKit
//
//  Created by MK on 2024/4/1.
//

import Foundation

public extension Logger {}

// MARK: - WSPrinter

public class WSPrinter {
    public init() {}
}

public extension WSPrinter {}

// MARK: Printer

extension WSPrinter: Printer {
    public func write(level _: Logger.Level, message _: String, tag _: String?, function _: String, file _: String, line _: UInt) {}
}
