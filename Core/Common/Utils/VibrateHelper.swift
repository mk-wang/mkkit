//
//  VibrateHelper.swift
//
//  Created by MK on 2023/5/31.
//

import AudioToolbox
import AVFoundation
import CoreHaptics
import Foundation

// MARK: - Vibrable

// https://stackoverflow.com/questions/41444274/how-to-check-if-haptic-engine-uifeedbackgenerator-is-supported/42057620#42057620

public protocol Vibrable {
    func vibrate()
}

// MARK: - VibrateHelper

public enum VibrateHelper {
    public enum Haptic {
        case selection

        case error
        case success
        case warning
        case light
        case medium
        case heavy

        @available(iOS 13.0, *)
        case soft
        @available(iOS 13.0, *)
        case rigid
    }

    // https://stackoverflow.com/questions/41444274/how-to-check-if-haptic-engine-uifeedbackgenerator-is-supported/42057620#42057620
    //  AudioServicesPlaySystemSound(1519) // Actuate "Peek" feedback (weak boom)
    //  AudioServicesPlaySystemSound(1520) // Actuate "Pop" feedback (strong boom)
    //  AudioServicesPlaySystemSound(1521) // Actuate "Nope" feedback (series of three weak booms)

    public enum Sound: SystemSoundID {
        case sytem = 0
        case peek = 1519
        case pop = 1520
        case nope = 1521
    }
}

extension VibrateHelper.Haptic {
    public var iOS13: Bool {
        if #available(iOS 13.0, *) {
            return self == .soft || self == .rigid
        } else {
            return false
        }
    }

    var notification: UINotificationFeedbackGenerator.FeedbackType? {
        switch self {
        case .error:
            return .error
        case .success:
            return .success
        case .warning:
            return .warning
        default:
            return nil
        }
    }

    var impact: UIImpactFeedbackGenerator.FeedbackStyle? {
        switch self {
        case .light:
            return .light
        case .medium:
            return .medium
        case .heavy:
            return .heavy
        default:
            if #available(iOS 13.0, *) {
                if self == .soft {
                    return .soft
                } else if self == .rigid {
                    return .rigid
                }
            }
            return nil
        }
    }
}

// MARK: - VibrateHelper.Haptic + Vibrable

extension VibrateHelper.Haptic: Vibrable {
    public func vibrate() {
        if self == .selection {
            let generator = UISelectionFeedbackGenerator()
            generator.prepare()

            DispatchQueue.main.async {
                generator.selectionChanged()
            }
            return
        }
        if let notification {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            DispatchQueue.main.async {
                generator.notificationOccurred(notification)
            }
            return
        }
        if let impact {
            let generator = UIImpactFeedbackGenerator(style: impact)
            generator.prepare()
            DispatchQueue.main.async {
                generator.impactOccurred()
            }
            return
        }
    }
}

// MARK: - VibrateHelper.Sound + Vibrable

extension VibrateHelper.Sound: Vibrable {
    public func vibrate() {
        let soundID = self == .sytem ? kSystemSoundID_Vibrate : rawValue
        DispatchQueue.main.async {
            AudioServicesPlaySystemSound(soundID)
        }
    }
}

public extension VibrateHelper {
    static let supportsHaptics: Bool = {
        #if targetEnvironment(simulator)
            return true
        #else
            if #available(iOS 13.0, *) {
                return CHHapticEngine.capabilitiesForHardware().supportsHaptics
            } else {
                return feedbackLevel > 1
            }
        #endif
    }()

    static let supportsSimpleHaptics: Bool = supportsHaptics || feedbackLevel > 0

    // 2: Haptic, iphone 7
    // 1: Simple Haptic, iPhone 6S
    // 0: None
    // https://stackoverflow.com/questions/41444274/how-to-check-if-haptic-engine-uifeedbackgenerator-is-supported/42057620#42057620
    static let feedbackLevel: Int = {
        // "_feedbackSupportLevel"
        let key = "_" + "poonlkmuCezzybdVofov".rot(n: 16)
        let value = UIDevice.current.value(forKey: key)
        let intVal = (value as? NSNumber)?.intValue ?? 0
        return intVal
    }()

    static func sessionFix() {
        if #available(iOS 13.0, *) {
            let session = AVAudioSession.sharedInstance()
            if !session.allowHapticsAndSystemSoundsDuringRecording {
                do {
                    try session.setAllowHapticsAndSystemSoundsDuringRecording(true)
                } catch {}
            }
        }
    }

    static func vibrate(preferHaptic: Haptic = .heavy, preferSound: Sound = .pop) {
        sessionFix()

        var vibrate: Vibrable?

        if supportsHaptics {
            vibrate = preferHaptic
        } else {
            let level = feedbackLevel
            vibrate = level == 0 ? .sytem : preferSound
        }

        vibrate?.vibrate()
    }
}
