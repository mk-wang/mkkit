//
//  AppLangExt.swift
//
//
//  Created by MK on 2022/4/1.
//

import Foundation
import OpenCombine

public extension Lang {
    private static var service: LangService {
        AppServiceManager.findService(LangService.self)!
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

    static var publisher: AnyPublisher<Lang?, Never> {
        service.publisher
    }

    static var list: [Lang] {
        service.langList
    }
}

// MARK: - LangService + AppSerivce

extension LangService: AppSerivce {
    public func initBeforeWindow() {
        lang.configDirection()
    }

    public func initAfterWindow(window _: UIWindow) {}
    public func onExit() {}
}

public extension CustomStringConvertible {
    var tr: String {
        let currentBundle = Lang.current.bundle

        if let text = currentBundle?.translate(for: self) {
            return text
        }

        let defaultBundle = Lang.default.bundle
        if currentBundle != defaultBundle {
            if let text = defaultBundle?.translate(for: self) {
                return text
            }
        }

        return description
    }
}

public extension Lang {
    static func makeIndex(_ index: Int) -> String {
        Lang.current.isRTL ? "· " : "\(index). "
    }
}
