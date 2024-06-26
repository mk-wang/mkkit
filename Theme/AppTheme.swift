//
//  AppTheme.swift
//
//  Created by MK on 2021/5/18.
//

import Foundation

// MARK: - AppTheme

public enum AppTheme: Int8 {
    case system = 0
    case light = 1
    case dark = 2
}

// MARK: Codable

extension AppTheme: Codable {}

public extension AppTheme {
    static var `default`: Self {
        if #available(iOS 13.0, *) {
            .system
        } else {
            .light
        }
    }

    static var isSytemSupported: Bool {
        if #available(iOS 13.0, *) {
            true
        } else {
            false
        }
    }

    static var list: [AppTheme] {
        var list: [AppTheme] = [.light, .dark]
        if AppTheme.isSytemSupported {
            list.append(.system)
        }
        return list
    }
}

// MARK: CustomStringConvertible

extension AppTheme: CustomStringConvertible {
    public var description: String {
        switch self {
        case .dark:
            "dark"
        case .light:
            "light"
        case .system:
            "system"
        }
    }
}
