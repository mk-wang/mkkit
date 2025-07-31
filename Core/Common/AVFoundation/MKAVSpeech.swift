//
//  MKAVSpeech.swift
//
//  Created by MK on 2021/8/4.
//

import AVFoundation
import Foundation

public extension MKAVSpeech {
    struct VoiceSetting {
        let identifier: String
        let language: String
    }

    enum VoiceStyle {
        case old
        case ios16
        case ios26

        public static let current: Self = if #available(iOS 26.0, *) {
            .ios26
        } else if #available(iOS 16.0, *) {
            .ios16
        } else {
            .old
        }
    }
}

public extension MKAVSpeech.VoiceStyle {
    func nameOf(identifier id: String) -> String? {
        guard id.isNotEmpty,
              let lastPoint = id.lastIndex(of: "."),
              let end = self == .old ? id.lastIndex(of: "-") : id.endIndex
        else {
            return nil
        }

        let start = id.index(after: lastPoint)
        return .init(id[start ..< end])
    }

    func settingOf(lang: Lang) -> MKAVSpeech.VoiceSetting? {
        guard lang.canSpeak else {
            return nil
        }

        var identifier: String?
        var language: String?

        let style = self
        switch lang {
        case .en:
            language = "en-US"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Samantha-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.en-US.Samantha"
            case .ios26:
                identifier = "com.apple.voice.super-compact.en-US.Samantha"
            }
        case .uk:
            language = "en-GB"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Daniel-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.en-GB.Daniel"
            case .ios26:
                identifier = "com.apple.voice.super-compact.en-GB.Daniel"
            }
        case .fr:
            language = "fr-CA"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Amelie-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.fr-CA.Amelie"
            case .ios26:
                identifier = "com.apple.voice.super-compact.fr-CA.Amelie"
            }
        case .zh_Hans:
            language = "zh-CN"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Ting-Ting-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.zh-CN.Tingting"
            case .ios26:
                identifier = "com.apple.voice.super-compact.zh-CN.Tingting"
            }
        case .zh_Hant:
            language = "zh-TW"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Mei-Jia-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.zh-TW.Meijia"
            case .ios26:
                identifier = "com.apple.voice.super-compact.zh-TW.Meijia"
            }
        case .it:
            language = "it-IT"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Alice-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.it-IT.Alice"
            case .ios26:
                identifier = "com.apple.voice.super-compact.it-IT.Alice"
            }
        case .es:
            language = "es-ES"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Monica-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.es-ES.Monica"
            case .ios26:
                identifier = "com.apple.voice.super-compact.es-ES.Monica"
            }
        case .es_mx:
            language = "es-MX"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Paulina-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.es-MX.Paulina"
            case .ios26:
                identifier = "com.apple.voice.super-compact.es-MX.Paulina"
            }
        case .de:
            language = "de-DE"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Anna-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.de-DE.Anna"
            case .ios26:
                identifier = "com.apple.voice.super-compact.de-DE.Anna"
            }
        case .pt_BR:
            language = "pt-BR"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Luciana-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.pt-BR.Luciana"
            case .ios26:
                identifier = "com.apple.voice.super-compact.pt-BR.Luciana"
            }
        case .pt,
             .pt_PT:
            language = "pt-PT"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Joana-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.pt-PT.Joana"
            case .ios26:
                identifier = "com.apple.voice.super-compact.pt-PT.Joana"
            }
        case .ru:
            language = "ru-RU"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Milena-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.ru-RU.Milena"
            case .ios26:
                identifier = "com.apple.voice.compact.ru-RU.Milena"
            }
        case .ja:
            language = "ja-JP"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Kyoko-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.ja-JP.Kyoko"
            case .ios26:
                identifier = "com.apple.voice.compact.ja-JP.Kyoko"
            }
        case .ko:
            language = "ko-KR"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Yuna-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.ko-KR.Yuna"
            case .ios26:
                identifier = "com.apple.voice.super-compact.ko-KR.Yuna"
            }
        case .tr:
            language = "tr-TR"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Yelda-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.tr-TR.Yelda"
            case .ios26:
                identifier = "com.apple.voice.super-compact.tr-TR.Yelda"
            }
        case .ar:
            switch style {
            case .old:
                language = "ar-SA"
                identifier = "com.apple.ttsbundle.Maged-compact"
            case .ios16:
                language = "ar-001"
                identifier = "com.apple.voice.compact.ar-001.Maged"
            case .ios26:
                identifier = "com.apple.voice.super-compact.ar-001.Maged"
            }
        case .id:
            language = "id-ID"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Damayanti-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.id-ID.Damayanti"
            case .ios26:
                identifier = "com.apple.voice.super-compact.id-ID.Damayanti"
            }
        case .pl:
            language = "pl-PL"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Zosia-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.pl-PL.Zosia"
            case .ios26:
                identifier = "com.apple.voice.super-compact.pl-PL.Zosia"
            }
        case .ro:
            language = "ro-RO"

            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Ioana-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.ro-RO.Ioana"
            case .ios26:
                identifier = "com.apple.voice.super-compact.ro-RO.Ioana"
            }
        case .hi:
            language = "hi-IN"
            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Lekha-compact"
            case .ios16:
                identifier = "com.apple.voice.compact.hi-IN.Lekha"
            case .ios26:
                identifier = "com.apple.voice.super-compact.hi-IN.Lekha"
            }
        case .ms_MY:
            language = "ms-MY"
            switch style {
            case .old:
                identifier = "com.apple.ttsbundle.Amira-compact"
//                identifier = nil
            case .ios16:
                identifier = "com.apple.voice.compact.ms-MY.Amira"
            case .ios26:
                identifier = "com.apple.voice.super-compact.ms-MY.Amira"
            }
        default:
            assert(!lang.canSpeak, "cannot speak \(lang)")
        }

        guard let identifier, let language else {
            return nil
        }

        return .init(identifier: identifier, language: language)
    }
}

public extension Lang {
    var canSpeak: Bool {
        canSpeak(style: .current)
    }

    func canSpeak(style: MKAVSpeech.VoiceStyle) -> Bool {
        guard self != .fa, self != .ur else {
            return false
        }

        guard style == .old else {
            return true
        }

        return self != .ms_MY
    }

    func newVoice(byIdentifier: Bool = true,
                  byLanguage: Bool = true) -> AVSpeechSynthesisVoice?
    {
        let style: MKAVSpeech.VoiceStyle = .current

        guard let setting = style.settingOf(lang: self) else {
            return nil
        }

        if byIdentifier, let voice = AVSpeechSynthesisVoice(identifier: setting.identifier) {
            return voice
        }

        if byLanguage, let voice = AVSpeechSynthesisVoice(language: setting.language) {
            return voice
        }

        return nil
    }

    func matchVoice(byIdentifier: Bool = true,
                    byName: Bool = true,
                    byLanguage: Bool = true) -> AVSpeechSynthesisVoice?
    {
        let style: MKAVSpeech.VoiceStyle = .current

        guard let setting = style.settingOf(lang: self) else {
            return nil
        }

        let voices = AVSpeechSynthesisVoice.speechVoices()

        if byIdentifier,
           let voice = voices.first(where: { $0.identifier == setting.identifier })
        {
            return voice
        }

        if byName,
           let name = style.nameOf(identifier: setting.identifier),
           let voice = voices.first(where: { style.nameOf(identifier: $0.identifier) == name })
        {
            return voice
        }

        if byLanguage {
            if let voice = voices.first(where: { $0.language == setting.language }) {
                return voice
            }

            if let country = setting.language.components(separatedBy: "-").first,
               let voice = voices.first(where: { $0.language.starts(with: country) })
            {
                return voice
            }
        }

        return nil
    }

    #if DEBUG_BUILD
        static func testAllVoices() {
            let style: MKAVSpeech.VoiceStyle = .current

            for lang in Lang.allCases {
                guard let setting = style.settingOf(lang: lang) else {
                    continue
                }

                assert(lang.newVoice(byIdentifier: true, byLanguage: false)?.identifier == setting.identifier, "newVoice byIdentifier \(lang)")
                assert(lang.newVoice(byIdentifier: false, byLanguage: true)?.language == setting.language, "newVoice byLanguage \(lang)")

                assert(lang.matchVoice(byIdentifier: true, byName: false, byLanguage: false)?.identifier == setting.identifier, "matchVoice byIdentifier \(lang)")
                assert(lang.matchVoice(byIdentifier: false, byName: true, byLanguage: false)?.identifier == setting.identifier, "matchVoice byName \(lang)")
                assert(lang.matchVoice(byIdentifier: false, byName: false, byLanguage: true)?.language == setting.language, "matchVoice byLanguage \(lang)")
            }
        }
    #endif
}

// MARK: - MKAVSpeech

open class MKAVSpeech: NSObject {
    public let synthesizer: AVSpeechSynthesizer
    public let voice: AVSpeechSynthesisVoice?

    public var isSpeaking: Bool {
        synthesizer.isSpeaking
    }

    public init(voice: AVSpeechSynthesisVoice?) {
        self.voice = voice
        synthesizer = AVSpeechSynthesizer()

        super.init()

        synthesizer.delegate = self
    }
}

public extension MKAVSpeech {
    @discardableResult
    func speech(text: String, speed: Float = 1.0, volume: Float = 1.0) -> AVSpeechUtterance? {
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate *= speed
        utterance.volume = volume
        utterance.voice = voice
        do {
            try synthesizer.speak(utterance)
            utterance.stateSubject = .init(.none)
            return utterance
        } catch {
            Logger.shared.error("MKAVSpeech speech \(text), error \(error)")
            return nil
        }
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func pause() {
        synthesizer.pauseSpeaking(at: .immediate)
    }

    var isPaused: Bool {
        synthesizer.isPaused
    }

    func resume() {
        synthesizer.continueSpeaking()
    }
}

// MARK: AVSpeechSynthesizerDelegate

extension MKAVSpeech: AVSpeechSynthesizerDelegate {
    public func speechSynthesizer(_: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        utterance.stateSubject?.value = .started
    }

    public func speechSynthesizer(_: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        utterance.stateSubject?.value = .finished
    }

    public func speechSynthesizer(_: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        utterance.stateSubject?.value = .cancelled
    }

    public func speechSynthesizer(_: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        utterance.stateSubject?.value = .paused
    }

    public func speechSynthesizer(_: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        utterance.stateSubject?.value = .continued
    }
}

public extension AVSpeechUtterance {
    enum State: Int, Equatable {
        case none
        case started
        case finished
        case cancelled
        case paused
        case continued

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue == rhs.rawValue
        }
    }

    fileprivate var stateSubject: CurrentValueSubjectType<State, Never>? {
        get {
            getAssociatedObject(&AssociatedKeys.kSubject) as? CurrentValueSubjectType<State, Never>
        }
        set {
            setAssociatedObject(&AssociatedKeys.kSubject, newValue)
        }
    }

    var statePublisher: AnyPublisherType<State, Never>? {
        stateSubject?.eraseToAnyPublisher()
    }

    private(set) var state: State? {
        get {
            stateSubject?.value
        }
        set {
            stateSubject?.value = newValue ?? .none
        }
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kSubject = 0
}
