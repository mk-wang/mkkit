//
//  LangExt.swift
//
//
//  Created by MK on 2022/4/1.
//

import Foundation

public extension Lang {
    private static var service: LangService {
        MKAppDelegate.shared!.findService(LangService.self)!
    }

    static var current: Lang {
        get {
            service.lang
        }
        set {
            service.lang = newValue
        }
    }

    static var `default`: Lang {
        service.default
    }

    static var rltPublisher: AnyPublisherType<Bool, Never> {
        service.rltPublisher
    }

    static var publisher: AnyPublisherType<Lang?, Never> {
        service.publisher
    }

    static var list: [Lang] {
        service.langList
    }

    static func reset() {
        current = service.system ?? service.default
    }
}

// MARK: - LangService + AppSerivce

extension LangService: AppSerivce {
    public func initBeforeWindow() {
        if applyLangDirection {
            lang.configDirection()
        }
    }
}

public extension CustomStringConvertible {
    var tr: String {
        let currentBundle = Lang.current.bundle

        let key = description

        if let text = currentBundle?.translate(for: key) {
            return text
        }

        let defaultBundle = Lang.default.bundle
        if currentBundle != defaultBundle {
            if let text = defaultBundle?.translate(for: key) {
                return text
            }
        }

        return key
    }
}

public extension Lang {
    static func makeIndex(_ index: Int) -> String {
        Lang.current.isRTL ? "· " : "\(index). "
    }
}
