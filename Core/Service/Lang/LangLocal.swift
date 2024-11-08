//
//  LangLocal.swift
//  Pods
//
//  Created by MK on 2024/11/8.
//

import OpenCombine

open class LangLocal<T> {
    private var data: [Lang: T] = [:]
    private var langObs: AnyCancellable?

    let restrictToCurrentLang: Bool
    let builder: ValueBuilder1<T, Lang>
    let lock: NSLocking?

    public init(restrictToCurrentLang: Bool = true,
                lock: NSLocking? = nil,
                builder: @escaping ValueBuilder1<T, Lang>)
    {
        self.builder = builder
        self.restrictToCurrentLang = restrictToCurrentLang
        self.lock = lock

        langObs = Lang.publisher
            .removeDuplicatesAndDrop()
            .receiveOnMain()
            .sink { [weak self] _ in
                self?.update(lang: .current)
            }
    }

    @discardableResult
    public func update(lang: Lang, value: T? = nil) -> T {
        update(lang: lang, newValue: value, shouldLock: true)
    }

    public var value: T {
        lock?.lock()
        defer { lock?.unlock() }

        let lang = Lang.current
        return data[lang] ?? update(lang: lang, shouldLock: false)
    }

    @discardableResult
    private func update(lang: Lang, newValue: T? = nil, shouldLock: Bool = true) -> T {
        if shouldLock { lock?.lock() }
        defer { if shouldLock { lock?.unlock() } }

        if restrictToCurrentLang {
            data.removeAll()
        }

        if newValue == nil, let value = data[lang] {
            return value
        }

        let value = newValue ?? builder(lang)
        data[lang] = value
        return value
    }
}
