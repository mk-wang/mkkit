//
//  Version.swift
//  Pods
//
//  Created by MK on 2025/3/6.
//

import Foundation

// MARK: - Version + Equatable

extension Version: Equatable {
    public static func == (lhs: Version, rhs: Version) -> Bool {
        lhs.current == rhs.current && lhs.previous == rhs.previous && lhs.install == rhs.install
    }
}

// MARK: - BuildIntValue

public protocol BuildIntValue {
    static var value: Int { get }
}

// MARK: - BuildInt3

public enum BuildInt3: BuildIntValue {
    public static var value: Int { 3 }
}

// MARK: - BuildInt4

public enum BuildInt4: BuildIntValue {
    public static var value: Int { 4 }
}

// MARK: - BuildVersion

public struct BuildVersion<T: BuildIntValue> {
    public let components: [Int]
    public let maxComponents = T.value

    public init(_ components: [Int]) {
        let diff = maxComponents - components.count
        if diff < 0 {
            self.components = Array(components.prefix(maxComponents))
        } else if diff > 0 {
            self.components = components + Array(repeating: 0, count: diff)
        } else {
            self.components = components
        }
    }

    public init(_ version: String) {
        self.init(version.split(separator: ".").compactMap { Int($0) })
    }
}

// MARK: Comparable, Codable

extension BuildVersion: Comparable, Codable {
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

public typealias BuildVersion4 = BuildVersion<BuildInt4>
public typealias BuildVersion3 = BuildVersion<BuildInt3>

public extension BuildVersion4 {
    var major: BuildVersion3 {
        .init(components)
    }

    var minor: Int {
        components.last ?? 0
    }
}

// MARK: - Version

public struct Version: Codable {
    public let current: BuildVersion4
    public let install: BuildVersion4
    public let previous: BuildVersion4?

    public init(current: BuildVersion4,
                install: BuildVersion4,
                previous: BuildVersion4? = nil)
    {
        self.current = current
        self.install = install
        self.previous = previous
    }

    public var isUpgrade: Bool {
        current > (previous ?? install)
    }
}
