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
        let shareTextBuilder: () -> String
        let appNameBuiler: () -> String
        let baseURLBuilder: (() -> URL)?

        static let empty = Config(appId: "", feedbackMail: "", shareTextBuilder: { "" }, appNameBuiler: { "" })

        public init(
            appId: String,
            feedbackMail: String,
            shareTextBuilder: @escaping () -> String,
            appNameBuiler: @escaping () -> String,
            baseURLBuilder: (() -> URL)? = nil
        ) {
            self.appId = appId
            self.feedbackMail = feedbackMail
            self.shareTextBuilder = shareTextBuilder
            self.appNameBuiler = appNameBuiler
            self.baseURLBuilder = baseURLBuilder
        }
    }

    public static var config: Config = .empty

    public static var appleId: String { config.appId }

    public static var feedbackMail: String { config.feedbackMail }

    public static var shareText: String { config.shareTextBuilder() }

    public static var appName: String { config.appNameBuiler() }

    public static var baseURL: URL? { config.baseURLBuilder?() }
}

public extension AppInfo {
    static let downloadURL: URL = .init(string: "https://apps.apple.com/app/id\(appleId)")!
    static let reviewURL: URL = .init(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(appleId)?action=write-review")!

    static let bundleIdentifier = Bundle.main.bundleIdentifier!

    static var displayName: String {
        bundleInfo(for: kCFBundleNameKey as String)!
    }

    static var buildNumber: String? {
        bundleInfo(for: kCFBundleVersionKey as String)
    }

    static var fullVersion: String {
        var text = "\(shortVersion)"
        if let buildNumber {
            text += ".\(buildNumber)"
        }
        return text
    }

    static var buildVersion: BuildVersion {
        .init(fullVersion)
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

    static var localeRegion: String? {
        if #available(iOS 16, *) {
            Locale.current.region?.identifier
        } else {
            Locale.current.regionCode
        }
    }

    static func bundleInfo(for key: String) -> String? {
        Bundle.main.object(forInfoDictionaryKey: key) as? String
    }

    static var appIcon: UIImage? {
        if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last
        {
            return UIImage(named: lastIcon)
        }

        return nil
    }
}
