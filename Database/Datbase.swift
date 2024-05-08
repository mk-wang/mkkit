//
//  Datbase.swift
//
//
//  Created by MK on 2022/5/11.
//

import Foundation
import MKKit
import OpenCombine
import SQLite

// MARK: - RecorderStatus

public typealias RowIDType = Int64

public extension RowIDType {
    var isValid: Bool {
        self >= 0
    }

    static let invalidRow: RowIDType = -1
}

// MARK: - Database

open class Database {
    public let path: String

    public private(set) var connection: SQLite.Connection?

    public init(path: String) {
        self.path = path
    }

    open func initDB() {
        do {
            connection = try SQLite.Connection(path)
            guard let connection else {
                Logger.shared.error("db error: no connection at \(path)", tag: "db")
                return
            }

            Logger.shared.debug("db init at \(path)", tag: "db")
            if let version = connection.userVersion {
                Logger.shared.info("db version \(version)", tag: "db")
            }

            try setupTables()
        } catch {
            connection = nil
            Logger.shared.error("db error: \(error) at \(path)", tag: "db")
        }
    }

    open func close() {
        Logger.shared.debug("close", tag: "db")
        connection = nil
    }

    open func setupTables() throws {}
}

// MARK: Database.ValueWrap

public extension Database {
    // MARK: - ValueWrap

    enum ValueWrap<T> {
        case empty
        case data(T)

        public var value: T? {
            switch self {
            case .empty:
                return nil
            case let .data(value):
                return value
            }
        }

        public static func from(_ value: T?) -> Self {
            value == nil ? .empty : .data(value!)
        }
    }
}
