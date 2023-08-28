//
//  MKAVSpeech.swift
//  YogaWorkout
//
//  Created by MK on 2021/8/4.
//

import AVFoundation
import Foundation
import MKKit
import OpenCombine

public extension Lang {
    var speechId: String {
        switch self {
        case .en,
             .uk:
            return "com.apple.ttsbundle.Samantha-compact"
        case .fr:
            return "com.apple.ttsbundle.Amelie-compact"
        case .zh_Hans:
            return "com.apple.ttsbundle.Ting-Ting-compact"
        case .zh_Hant:
            return "com.apple.ttsbundle.Mei-Jia-compact"
        case .it:
            return "com.apple.ttsbundle.Alice-compact"
        case .es:
            return "com.apple.ttsbundle.Monica-compact"
        case .es_mx:
            return "com.apple.ttsbundle.Paulina-compact"
        case .de:
            return "com.apple.ttsbundle.Anna-compact"
        case .pt_BR:
            return "com.apple.ttsbundle.Luciana-compact"
        case .pt_PT:
            return "com.apple.ttsbundle.Joana-compact"
        case .ru:
            return "com.apple.ttsbundle.Milena-compact"
        case .ja:
            return "com.apple.ttsbundle.Kyoko-compact"
        case .ko:
            return "com.apple.ttsbundle.Yuna-compact"
        case .tr:
            return "com.apple.ttsbundle.Luciana-compact"
        case .ar:
            return "com.apple.ttsbundle.Maged-compact"
        case .id:
            return "com.apple.ttsbundle.Damayanti-compact"
        case .pl:
            return "com.apple.ttsbundle.Zosia-compact"
        case .ro:
            return "com.apple.ttsbundle.Ioana-compact"
        case .fa:
            return "" // TODO:
        }
    }

    var speechLang: String {
        switch self {
        case .en,
             .uk:
            return "en-US"
        case .fr:
            return "fr-CA"
        case .zh_Hans:
            return "zh-CN"
        case .zh_Hant:
            return "zh-TW"
        case .it:
            return "it-IT"
        case .es:
            return "es-ES"
        case .es_mx:
            return "es-MX"
        case .de:
            return "de-DE"
        case .pt_BR:
            return "pt-BR"
        case .pt_PT:
            return "pt-PT"
        case .ru:
            return "ru-RU"
        case .ja:
            return "ja-JP"
        case .ko:
            return "ko-KR"
        case .tr:
            return "tr-TR"
        case .ar:
            return "ar-SA"
        case .id:
            return "id-ID"
        case .pl:
            return "pl-PL"
        case .ro:
            return "ro-RO"
        case .fa:
            return ""
        }
    }

    var canSpeeh: Bool {
        speechLang.isNotEmpty
    }
}

// MARK: - MKAVSpeech

open class MKAVSpeech: NSObject {
    public let lang: Lang
    public let synthesizer: AVSpeechSynthesizer
    public let voice: AVSpeechSynthesisVoice?

    public var isSpeaking: Bool {
        synthesizer.isSpeaking
    }

    public init(lang: Lang) {
        self.lang = lang
        synthesizer = AVSpeechSynthesizer()
        voice = AVSpeechSynthesisVoice(identifier: lang.speechId) ?? AVSpeechSynthesisVoice(language: lang.speechLang)

        super.init()

        synthesizer.delegate = self
    }
}

public extension MKAVSpeech {
    @discardableResult
    func speech(text: String, speed: Float = 1.0, volume: Float = 1.0) -> AVSpeechUtterance? {
        // 别的项目这样处理 ， 我不知道为什么
        let converted = (text as NSString).replacingOccurrences(of: "-", with: " ")
        let utterance = AVSpeechUtterance(string: converted)
        utterance.rate *= speed
        utterance.volume = volume
        utterance.voice = voice
        do {
            try synthesizer.speak(utterance)
            utterance.stateSubject = .init(.none)
            return utterance
        } catch _ {
            return nil
        }
    }

    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
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

    fileprivate var stateSubject: CurrentValueSubject<State, Never>? {
        get {
            getAssociatedObject(&AssociatedKeys.kSubject) as? CurrentValueSubject<State, Never>
        }
        set {
            setAssociatedObject(&AssociatedKeys.kSubject, newValue)
        }
    }

    var statePublisher: AnyPublisher<State, Never>? {
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
