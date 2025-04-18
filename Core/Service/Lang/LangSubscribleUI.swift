//
//  LangSubscribleUI.swift
//
//
//  Created by MK on 2022/3/31.
//

import UIKit

// MARK: - LangSubscribleUI

public protocol LangSubscribleUI: NSObject {
    func langKeyChanged(key: String, text: String?)
}

public extension LangSubscribleUI {
    func langConfig(key: String, textBuiler: TextBuilder? = nil) {
        textBuilder = textBuiler ?? { $0.tr }
        langKey = key
    }

    private var langCancellable: AnyCancellableType? {
        get {
            getAssociatedObject(&AssociatedKeys.kLangCancellable) as? AnyCancellableType
        }
        set {
            setAssociatedObject(&AssociatedKeys.kLangCancellable, newValue)
        }
    }

    private var langKey: String? {
        get {
            getAssociatedObject(&AssociatedKeys.kLangKey) as? String
        }
        set {
            setAssociatedObject(&AssociatedKeys.kLangKey, newValue)
            if let key = newValue {
                langCancellable = Lang.publisher.sink { [weak self] _ in
                    guard let self else { return }
                    var text: String?
                    if let builder = textBuilder {
                        text = builder(key)
                    }
                    langKeyChanged(key: key, text: text)
                }
            } else {
                langCancellable = nil
            }
        }
    }

    private var textBuilder: TextBuilder? {
        get {
            getAssociatedObject(&AssociatedKeys.kTextBuilder) as? TextBuilder
        }
        set {
            setAssociatedObject(&AssociatedKeys.kTextBuilder, newValue)
        }
    }

    typealias TextBuilder = (String) -> String?
}

// MARK: - UILabel + LangSubscribleUI

extension UILabel: LangSubscribleUI {
    public func langKeyChanged(key _: String, text: String?) {
        self.text = text
    }
}

// MARK: - UIButton + LangSubscribleUI

extension UIButton: LangSubscribleUI {
    public func langKeyChanged(key _: String, text: String?) {
        setTitle(text, for: .normal)
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kLangKey = 0
    static var kTextBuilder = 0
    static var kLangCancellable = 0
}
