//
//  LangService.swift
//
//
//  Created by MK on 2022/3/23.
//

import Foundation
#if canImport(OpenCombine)
    import OpenCombine
#elseif canImport(Combine)
    import Combine
#endif

// MARK: - LangService

open class LangService {
    public init(subject: CurrentValueSubject<Lang?, Never>, list: [Lang], default: Lang) {
        langSubject = subject
        langList = list
        self.default = `default`
        system = Lang.system(list: list)
    }

    private let langSubject: CurrentValueSubject<Lang?, Never>
    public lazy var publisher = langSubject.eraseToAnyPublisher()
    public lazy var rltPublisher = langSubject.map { [weak self] in
        self?.getLang($0).isRTL ?? false
    }.removeDuplicates().eraseToAnyPublisher()

    public let langList: [Lang]
    public let `default`: Lang
    public let system: Lang?

    convenience init(lang: Lang) {
        self.init(subject: .init(lang), list: [lang], default: lang)
    }
}

public extension LangService {
    var fallback: Lang {
        system ?? .default
    }

    var lang: Lang {
        get {
            getLang(langSubject.value)
        } set {
            if langSubject.value != newValue {
                if langSubject.value?.isRTL != newValue.isRTL {
                    newValue.configDirection()
                }
                langSubject.value = newValue
            }
        }
    }

    private func getLang(_ lang: Lang?) -> Lang {
        lang ?? fallback
    }
}
