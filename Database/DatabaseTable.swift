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

    func dropTable(ifExists: Bool = true) throws {
        try run(table.drop(ifExists: ifExists))
    }

    @discardableResult
    func cleanTable() throws -> Bool {
        guard let connection else {
            return false
        }
        try connection.run(table.delete())
        return true
    }
}

public extension DatabaseTable {
    func loadData<T: Decodable>(limit: Int? = nil,
                                offset: Int? = nil,
                                order: Expressible? = nil,
                                orders: [Expressible]? = nil,
                                filter: ValueBuilder1<SQLite.QueryType, SQLite.QueryType>? = nil) -> [T]
    {
        var list = [T]()
        guard let connection else {
            return list
        }

        do {
            var query: SQLite.QueryType = table

            if let filter {
                query = filter(query)
            }

            if let limit {
                if let offset {
                    query = query.limit(limit, offset: offset)
                } else {
                    query = query.limit(limit)
                }
            }

            if let order {
                query = query.order(order)
            }

            if let orders {
                query = query.order(orders)
            }

            list = try connection.prepare(query).compactMap { row in
                do {
                    let recorder: T = try row.decode()
                    return recorder
                } catch {
                    Logger.shared.error("loadData \(error)")
                    return nil
                }
            }
        } catch {
            Logger.shared.error("loadData \(error)")
        }

        return list
    }
}
