//
//  LangService.swift
//
//
//  Created by MK on 2022/3/23.
//

import Foundation
import OpenCombine

// MARK: - LangService

open class LangService {
    public init(subject: CurrentValueSubject<Lang?, Never>, list: [Lang], default: Lang) {
        langSubject = subject
        langList = list
        self.default = `default`

        if let text = NSLocale.preferredLanguages.first {
            system = Lang.from(text: text, list: langList)
        } else {
            system = nil
        }
    }

    private let langSubject: CurrentValueSubject<Lang?, Never>
    public lazy var publisher = langSubject.eraseToAnyPublisher()

    public let langList: [Lang]
    public let `default`: Lang
    public let system: Lang?
}

// MARK: AppSerivce

public extension LangService {
    var lang: Lang {
        get {
            langSubject.value ?? (system ?? self.default)
        } set {
            if langSubject.value != newValue {
                newValue.configDirection()
                langSubject.value = newValue
            }
        }
    }
}
