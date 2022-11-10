//
//  NSURLExt.swift
//
//
//  Created by MK on 2022/4/28.
//

import Foundation

extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
    }

    public func relativePath(from base: URL) -> String {
        let destComponents = standardized.pathComponents
        let baseComponents = base.standardized.pathComponents

        // Find number of common path components
        var i = 0
        while i < destComponents.count, i < baseComponents.count,
              destComponents[i] == baseComponents[i]
        {
            i += 1
        }

        // Build relative path
        var relComponents = Array(repeating: "..", count: baseComponents.count - i)
        relComponents.append(contentsOf: destComponents[i...])
        return relComponents.joined(separator: "/")
    }

    func bookmark(request: Bool) throws -> Data? {
        let requested = !request && startAccessingSecurityScopedResource()
        defer {
            if requested {
                stopAccessingSecurityScopedResource()
            }
        }

        let data = try bookmarkData(
            options: [],
            includingResourceValuesForKeys: nil,
            relativeTo: nil
        )

        return data
    }
}
