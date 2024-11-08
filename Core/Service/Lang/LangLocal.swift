//
//  LangLocal.swift
//  Pods
//
//  Created by MK on 2024/11/8.
//

import OpenCombine

open class LangLocal<T> {
    private var data: [Lang: T]
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

        let lang = Lang.current
        data = [lang: builder(lang)]

        langObs = Lang.publisher
            .removeDuplicatesAndDrop()
            .sink { [weak self] _ in
                self?.updateData()
            }
    }

    public func updateData(withLock: Bool = true) {
        if withLock {
            lock?.lock()
        }

        if restrictToCurrentLang {
            data.removeAll()
        }
        let lang = Lang.current
        data[lang] = builder(lang)

        if withLock {
            lock?.unlock()
        }
    }

    public var value: T {
        lock?.lock()
        defer { lock?.unlock() }

        if data[Lang.current] == nil {
            updateData(withLock: false)
        }

        return data[Lang.current]!
    }
}
