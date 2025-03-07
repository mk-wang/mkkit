//
//  Version.swift
//  Pods
//
//  Created by MK on 2025/3/6.
//

import Foundation

// MARK: - BuildIntValue

public protocol BuildIntValue {
    static var value: Int { get }
    associatedtype Lower: BuildIntValue
    associatedtype Higher: BuildIntValue
}

// MARK: - BuildIntNil

public enum BuildIntNil: BuildIntValue {
    public static var value: Int { 0 }
    public typealias Lower = BuildIntNil
    public typealias Higher = BuildIntNil
}

// MARK: - BuildInt1

public enum BuildInt1: BuildIntValue {
    public static var value: Int { 1 }
    public typealias Lower = BuildIntNil
    public typealias Higher = BuildInt2
}

// MARK: - BuildInt2

public enum BuildInt2: BuildIntValue {
    public static var value: Int { 2 }
    public typealias Lower = BuildInt1
    public typealias Higher = BuildInt3
}

// MARK: - BuildInt3

public enum BuildInt3: BuildIntValue {
    public static var value: Int { 3 }
    public typealias Lower = BuildInt2
    public typealias Higher = BuildInt4
}

// MARK: - BuildInt4

public enum BuildInt4: BuildIntValue {
    public static var value: Int { 4 }
    public typealias Lower = BuildInt3
    public typealias Higher = BuildIntNil
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

public extension BuildVersion {
    static func checkVersion(_ version: String) -> BuildVersion? {
        let regex = #"^\d+(\.\d+)*$"#
        guard version.range(of: regex, options: .regularExpression) != nil else {
            return nil
        }
        let components = version.split(separator: ".").compactMap { Int($0) }
        guard components.isNotEmpty else {
            return nil
        }
        return BuildVersion(components)
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

public extension BuildVersion {
    func cast<R: BuildIntValue>() -> BuildVersion<R> {
        .init(components)
    }

    var lower: BuildVersion<T.Lower>? {
        T.Lower.value == 0 ? nil : cast()
    }

    var higher: BuildVersion<T.Higher>? {
        T.Higher.value == 0 ? nil : cast()
    }
}

public typealias BuildVersion4 = BuildVersion<BuildInt4>
public typealias BuildVersion3 = BuildVersion<BuildInt3>

public extension BuildVersion4 {
    var major: BuildVersion3 {
        lower ?? cast()
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

// MARK: Equatable

extension Version: Equatable {
    public static func == (lhs: Version, rhs: Version) -> Bool {
        lhs.current == rhs.current && lhs.previous == rhs.previous && lhs.install == rhs.install
    }
}
