//
//  Lang.swift
//
//
//  Created by MK on 2022/3/18.
//

import Foundation

// MARK: - Lang

public enum Lang: String {
    case en
    case fr
    case it
    case es
    case es_mx = "es-MX"
    case de
    case ru
    case ja
    case ko
    case tr
    case ar
    case fa
    case ro
    case id
    case pl
    case uk
    case pt_BR = "pt-BR"
    case pt_PT = "pt-PT"
    case zh_Hans = "zh-Hans"
    case zh_Hant = "zh-Hant"

    private static var configs = [Lang: Bundle]()

    public var bundle: Bundle? {
        if let bundle = Self.configs[self] {
            return bundle
        }

        if let bundle = porjBundle(for: rawValue) {
            Self.configs[self] = bundle
            return bundle
        }

        let altertName = rawValue.replacingOccurrences(of: "-", with: "_")
        if altertName != rawValue, let bundle = porjBundle(for: altertName) {
            Self.configs[self] = bundle
            return bundle
        }
        return nil
    }

    private func porjBundle(for name: String) -> Bundle? {
        if let path = Bundle.main.path(forResource: name, ofType: "lproj") {
            return Bundle(path: path)
        }
        return nil
    }

    public var short: String {
        rawValue.short
    }
}

// MARK: CustomStringConvertible

extension Lang: CustomStringConvertible {
    public var description: String {
        switch self {
        case .en:
            return "English"
        case .fr:
            return "Français"
        case .zh_Hans:
            return "简体中文"
        case .zh_Hant:
            return "繁體中文"
        case .id:
            return "Indonesia"
        case .it:
            return "Italiano"
        case .es:
            return "Español"
        case .de:
            return "Deutsch"
        case .pt_BR:
            return "Português (Brasil)"
        case .ru:
            return "Русский"
        case .ja:
            return "日本語"
        case .ko:
            return "한국어"
        case .tr:
            return "Türkçe"
        case .ar:
            return "العربية"
        case .fa:
            return "فارسی"
        case .es_mx:
            return "Español (México)"
        case .ro:
            return "Român"
        case .pt_PT:
            return "Português"
        case .pl:
            return "Polski"
        case .uk:
            return "Українська"
        }
    }

    public var fixName: String {
        if self == .pt_BR {
            return Lang.pt_PT.description
        } else {
            return description
        }
    }
}

public extension Lang {
    var androidName: String {
        switch self {
        case .zh_Hans:
            return "zh_CN"
        case let x where x.rawValue.hasPrefix("zh-"):
            return "zh_TW"
        case .pt_BR,
             .pt_PT:
            return "pt"
        case .id:
            return "in_ID"
        case .pl,
             .uk:
            return rawValue // TODO:
        default:
            return rawValue
        }
    }
}

public extension Lang {
    var flagEmoji: String {
        switch self {
        case .en:
            return "🇺🇸"
        case .fr:
            return "🇫🇷"
        case .it:
            return "🇮🇹"
        case .es:
            return "🇪🇸"
        case .de:
            return "🇩🇪"
        case .ru:
            return "🇷🇺"
        case .ja:
            return "🇯🇵"
        case .ko:
            return "🇰🇷"
        case .tr:
            return "🇹🇷"
        case .ar:
            return "🇸🇦"
        case .fa:
            return "🇮🇷"
        case .pt_BR:
            return "🇧🇷"
        case .zh_Hans:
            return "🇨🇳"
        case .zh_Hant:
            return "🇨🇳"
        case .id:
            return "🇮🇩"
        case .es_mx:
            return "🇲🇽"
        case .ro:
            return "🇷🇴"
        case .pt_PT:
            return "🇵🇹"
        case .pl:
            return "🇵🇱"
        case .uk:
            return "🇺🇦"
        }
    }
}

// MARK: Equatable, Codable

extension Lang: Equatable, Codable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
}

public extension Lang {
    static func system(list: [Self]) -> Self? {
        if let first = NSLocale.preferredLanguages.first,
           let lang = Lang(rawValue: first),
           list.contains(lang)
        {
            return lang
        }

        let langs = list.map(\.rawValue)
        if let first = Bundle.preferredLocalizations(from: langs).first,
           let lang = Lang(rawValue: first),
           list.contains(lang)
        {
            return lang
        }

        return nil
    }

    static func from(text: String, list: [Self]) -> Self? {
        if let lang = Lang(rawValue: text), list.contains(lang) {
            return lang
        }

        let textShort = text.short
        guard textShort != text else {
            return nil
        }

        if let lang = Lang(rawValue: textShort), list.contains(lang) {
            return lang
        }

        for lang in list {
            let langShort = lang.short
            guard langShort != lang.rawValue, langShort == textShort else {
                continue
            }

            var guess: Lang?
            if langShort == "zh" {
                if text.contains("Hans") {
                    guess = .zh_Hans
                } else if text.contains("Hant") {
                    guess = .zh_Hant
                }
            } else if langShort == "es" {
                if text.contains("MX") {
                    guess = .es_mx
                }
            } else if langShort == "pt" {
                if text.contains("BR") {
                    guess = .pt_BR
                }
            }

            if let guess, list.contains(guess) {
                return guess
            }
            return lang
        }

        return nil
    }
}

private extension String {
    var short: String {
        guard let index = firstIndex(where: { $0 == "_" || $0 == "-" }) else {
            return self
        }
        return substring(to: index)
    }
}
