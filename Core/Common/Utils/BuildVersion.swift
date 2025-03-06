//
//  BuildVersion.swift
//  Pods
//
//  Created by MK on 2025/3/6.
//

import Foundation

// MARK: - BuildVersion

public struct BuildVersion {
    static let maxComponents = 4

    public let components: [Int]

    public init(_ version: String) {
        var parsedComponents = version.split(separator: ".").compactMap { Int($0) }

        if parsedComponents.count > BuildVersion.maxComponents {
            parsedComponents = Array(parsedComponents.prefix(BuildVersion.maxComponents))
        } else {
            while parsedComponents.count < BuildVersion.maxComponents {
                parsedComponents.append(0)
            }
        }

        components = parsedComponents
    }
}

// MARK: Comparable

extension BuildVersion: Comparable {
    public static func < (lhs: BuildVersion, rhs: BuildVersion) -> Bool {
        for (left, right) in zip(lhs.components, rhs.components) {
            if left < right {
                return true
            } else if left > right {
                return false
            }
        }
        return false
    }

    public static func == (lhs: BuildVersion, rhs: BuildVersion) -> Bool {
        lhs.components == rhs.components
    }
}

// MARK: CustomStringConvertible

extension BuildVersion: CustomStringConvertible {
    public var description: String {
        components.map { String($0) }.joined(separator: ".")
    }
}

// MARK: Codable

extension BuildVersion: Codable {}
