//
//  DatabaseTable.swift
//  MKKit
//
//  Created by MK on 2024/5/8.
//

import Foundation
import SQLite

// MARK: - DatabaseTable

open class DatabaseTable {
    public let name: String

    public let table: SQLite.Table

    weak var database: Database?

    public init(database: Database, name: String) {
        self.database = database
        self.name = name
        table = SQLite.Table(name)
    }

    open func setup() throws {}
}

public extension DatabaseTable {
    var connection: SQLite.Connection? {
        database?.connection
    }

    enum TableError: Error {
        case noDataIntance
    }
}

public extension DatabaseTable {
    func run(_ statement: String, _ bindings: [Binding?]? = nil) throws -> Statement {
        guard let connection else {
            throw TableError.noDataIntance
        }
        if let bindings {
            return try connection.run(statement, bindings)
        } else {
            return try connection.run(statement)
        }
    }

    func createTable(temporary: Bool = false,
                     ifNotExists: Bool = true,
                     withoutRowid: Bool = false,
                     builder: VoidFunction1<TableBuilder>) throws
    {
        try run(table.create(temporary: temporary,
                             ifNotExists: ifNotExists,
                             withoutRowid: withoutRowid,
                             block: builder))
    }
}

// public extension DatabaseTable {
//    public func prepare(_ statement: String, _ bindings: [Binding?]) throws -> Statement {
//        guard let connection else {
//            throw TableError.noDataIntance
//        }
//        return try connection.prepare(statement, bindings)
//    }
// }

//
//// MARK: DatabaseTable.TableError
//
// public extension DatabaseTable {
//    enum PrimaryKey {
//        case none
//        case primary
//        case autoincrement
//    }
//
//    func newField<T: Value>(name: String, type _: T.Type) -> Expression<T> {
//        Expression<T>(name)
//    }
//
//    @discardableResult
//    func addColumn<T: Value>(builder: TableBuilder,
//                             name: String,
//                             type: T.Type,
//                             primaryKey: PrimaryKey = .none,
//                             check: Expression<Bool>? = nil,
//                             defaultValue: Expression<T>? = nil) -> Expression<T>
//    {
//        guard primaryKey != .autoincrement else {
//            if T.self == Int64.self {
//                let field = newField(name: name, type: Int64.self)
//                builder.column(field, primaryKey: .autoincrement)
//                return field as! Expression<T>
//            } else {
//                fatalError("only Int64 can be autoincrement")
//            }
//        }
//
//        let field = newField(name: name, type: type)
//        builder.column(field, primaryKey: primaryKey == .primary, check: check, defaultValue: defaultValue)
//        return field
//    }
// }
