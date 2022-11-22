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

public extension String {
    var tr: String {
        var text = Lang.current.bundle.translate(for: self)
        if text == nil, Lang.current != Lang.default {
            text = Lang.default.bundle.translate(for: self)
        }
        return text ?? self
    }
}
