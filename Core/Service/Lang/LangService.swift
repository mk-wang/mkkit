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
        system = Lang.system(list: list)
    }

    private let langSubject: CurrentValueSubject<Lang?, Never>
    public lazy var publisher = langSubject.eraseToAnyPublisher()
    public lazy var rltPublisher = langSubject.map { $0?.isRTL ?? false }.removeDuplicates().eraseToAnyPublisher()

    public let langList: [Lang]
    public let `default`: Lang
    public let system: Lang?
}

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
