//
//  AppInfo.swift
//
//
//  Created by MK on 2022/3/18.
//

import Foundation
import UIKit

// MARK: - AppInfo

public enum AppInfo {
    public struct Config {
        let appId: String
        let feedbackMail: String
        let shareText: String
        let appNameBuiler: () -> String

        static let empty = Config(appId: "", feedbackMail: "", shareText: "", appNameBuiler: { "" })
    }

    public static var config: Config = .empty

    public static var appleId: String { config.appId }

    public static var feedbackMail: String { config.feedbackMail }

    public static var shareText: String { config.shareText }

    public static var appName: String { config.appNameBuiler() }
}

public extension AppInfo {
    static var downloadURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appleId)")!
    }

    static let bundleIdentifier = Bundle.main.bundleIdentifier!

    static var displayName: String {
        bundleInfo(for: kCFBundleNameKey as String)!
    }

    static var buildNumber: String? {
        bundleInfo(for: kCFBundleVersionKey as String)
    }

    static var fullVersion: String {
        var text = "\(shortVersion)"
        if let buildNumber = Self.buildNumber {
            text += ".\(buildNumber)"
        }
        return text
    }

    static var shortVersion: String {
        bundleInfo(for: "CFBundleShortVersionString")!
    }

    static var systemVersion: String {
        UIDevice.current.systemVersion
    }

    static var preferredLanguage: String? {
        Locale.preferredLanguages.first
    }

    static var localeIdentifier: String? {
        Locale.current.identifier
    }

    static func bundleInfo(for key: String) -> String? {
        Bundle.main.object(forInfoDictionaryKey: key) as? String
    }
}
