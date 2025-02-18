//
//  Sound.swift
//  SwiftySound
//
//  Created by Adam Cichy on 21/02/17.
//
//  Copyright (c) 2017 Adam Cichy
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import AVFoundation
import Foundation

#if os(iOS) || os(tvOS)
    /// SoundCategory is a convenient wrapper for AVAudioSessions category constants.
    public enum SoundCategory {
        /// Equivalent of AVAudioSession.Category.ambient.
        case ambient
        /// Equivalent of AVAudioSession.Category.soloAmbient.
        case soloAmbient
        /// Equivalent of AVAudioSession.Category.playback.
        case playback
        /// Equivalent of AVAudioSession.Category.record.
        case record
        /// Equivalent of AVAudioSession.Category.playAndRecord.
        case playAndRecord

        fileprivate var avFoundationCategory: AVAudioSession.Category {
            switch self {
            case .ambient:
                .ambient
            case .soloAmbient:
                .soloAmbient
            case .playback:
                .playback
            case .record:
                .record
            case .playAndRecord:
                .playAndRecord
            }
        }
    }
#endif

// MARK: - Sound

/// Sound is a class that allows you to easily play sounds in Swift. It uses AVFoundation framework under the hood.
open class Sound {
    // MARK: - Global settings

    /// Number of AVAudioPlayer instances created for every sound. SwiftySound creates 5 players for every sound to make sure that it will be able to play the same sound more than once. If your app doesn't need this functionality, you can reduce the number of players to 1 and reduce memory usage. You can increase the number if your app plays the sound more than 5 times at the same time.
    public static var playersPerSound: Int = 5 {
        didSet {
            stopAll()
            sounds.removeAll()
        }
    }

    private var volumeTimer: SwiftTimer?

    private static var sounds = [URL: Sound]()

    private static let defaultsKey = "com.moonlightapps.SwiftySound.enabled"

    /// Globally enable or disable sound. This setting value is stored in UserDefaults and will be loaded on app launch.
    public static var enabled: Bool = !UserDefaults.standard.bool(forKey: defaultsKey) { didSet {
        let value = !enabled
        UserDefaults.standard.set(value, forKey: defaultsKey)
        if value {
            stopAll()
        }
    }
    }

    private let players: [Player]

    private var counter = 0

    /// The class that is used to create `Player` instances. Defaults to `AVAudioPlayer`.
    public static var playerClass: Player.Type = AVAudioPlayer.self

    /// The bundle used to load sounds from filenames. The default value of this property is Bunde.main. It can be changed to load sounds from another bundle.
    public static var soundsBundle: Bundle = .main

    // MARK: - Initialization

    /// Create a sound object.
    ///
    /// - Parameter url: Sound file URL.
    public init?(url: URL) {
        let playersPerSound = max(Sound.playersPerSound, 1)
        var myPlayers: [Player] = []
        myPlayers.reserveCapacity(playersPerSound)
        for _ in 0 ..< playersPerSound {
            do {
                let player = try Sound.playerClass.init(contentsOf: url)
                myPlayers.append(player)
            } catch {
                Logger.shared.error("SwiftySound initialization error: \(error)")
            }
        }
        if myPlayers.isEmpty {
            return nil
        }
        players = myPlayers
        NotificationCenter.default.addObserver(self, selector: #selector(Sound.stopNoteRcv), name: Sound.stopNotificationName, object: nil)
    }

    public init?(data: Data, fileTypeHint: String?) {
        let playersPerSound = max(Sound.playersPerSound, 1)
        var myPlayers: [Player] = []
        myPlayers.reserveCapacity(playersPerSound)
        for _ in 0 ..< playersPerSound {
            do {
                let player = try Sound.playerClass.init(data: data, fileTypeHint: fileTypeHint)
                myPlayers.append(player)
            } catch {
                Logger.shared.error("SwiftySound initialization error: \(error)")
            }
        }
        if myPlayers.isEmpty {
            return nil
        }
        players = myPlayers
        NotificationCenter.default.addObserver(self, selector: #selector(Sound.stopNoteRcv), name: Sound.stopNotificationName, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: Sound.stopNotificationName, object: nil)
    }

    @objc private func stopNoteRcv() {
        stop()
    }

    private static let stopNotificationName = Notification.Name("com.moonlightapps.SwiftySound.stopNotification")

    // MARK: - Main play method

    /// Play the sound.
    ///
    /// - Parameter numberOfLoops: Number of loops. Specify a negative number for an infinite loop. Default value of 0 means that the sound will be played once.
    /// - Returns: If the sound was played successfully the return value will be true. It will be false if sounds are disabled or if system could not play the sound.
    @discardableResult public func play(numberOfLoops: Int = 0, completion: PlayerCompletion? = nil) -> Bool {
        volumeTimer = nil
        if !Sound.enabled {
            return false
        }
        paused = false
        counter = (counter + 1) % players.count
        let player = players[counter]
        return player.play(numberOfLoops: numberOfLoops, completion: completion)
    }

    @discardableResult public func infiniteLoopPlay() -> Bool {
        play(numberOfLoops: -1, completion: nil)
    }

    // MARK: - Stop playing

    /// Stop playing the sound.
    public func stop(fadeDuration: TimeInterval? = nil) {
        volumeTimer = nil

        if let fadeDuration {
            players.forEach { $0.setVolume(0, fadeDuration: fadeDuration) }
            weak var weakSelf = self
            volumeTimer = SwiftTimer(interval: .fromSeconds(fadeDuration),
                                     handler: { _ in
                                         weakSelf?.players.forEach { $0.stop() }
                                         weakSelf?.paused = false
                                     })
            volumeTimer?.start()
        } else {
            players.forEach { $0.stop() }
            paused = false
        }
    }

    /// Pause current playback.
    public func pause(fadeDuration: TimeInterval? = nil) {
        volumeTimer = nil

        let player = players[counter]
        if let fadeDuration {
            player.setVolume(0, fadeDuration: fadeDuration)
            weak var weakSelf = self
            volumeTimer = SwiftTimer(interval: .fromSeconds(fadeDuration),
                                     handler: { [weak player] _ in
                                         player?.pause()
                                         weakSelf?.paused = true
                                     })
            volumeTimer?.start()
        } else {
            player.pause()
            paused = true
        }
    }

    /// Resume playing.
    @discardableResult public func resume(volume: Float? = nil) -> Bool {
        volumeTimer = nil

        if paused {
            let player = players[counter]
            if let volume {
                player.volume = volume
            }
            player.resume()
            paused = false
            return true
        }
        return false
    }

    /// Indicates if the sound is currently playing.
    public var playing: Bool {
        players[counter].isPlaying
    }

    /// Indicates if the sound is paused.
    public private(set) var paused: Bool = false

    // MARK: - Prepare sound

    /// Prepare the sound for playback
    ///
    /// - Returns: True if the sound has been prepared, false in case of error
    @discardableResult public func prepare() -> Bool {
        let nextIndex = (counter + 1) % players.count
        return players[nextIndex].prepareToPlay()
    }

    public func reset() {
        for player in players {
            player.reset()
        }
    }

    // MARK: - Convenience static methods

    /// Play sound from a sound file.
    ///
    /// - Parameters:
    ///   - file: Sound file name.
    ///   - fileExtension: Sound file extension.
    ///   - numberOfLoops: Number of loops. Specify a negative number for an infinite loop. Default value of 0 means that the sound will be played once.
    /// - Returns: If the sound was played successfully the return value will be true. It will be false if sounds are disabled or if system could not play the sound.
    @discardableResult public static func play(file: String, fileExtension: String? = nil, numberOfLoops: Int = 0) -> Bool {
        if let url = url(for: file, fileExtension: fileExtension) {
            return play(url: url, numberOfLoops: numberOfLoops)
        }
        return false
    }

    /// Play a sound from URL.
    ///
    /// - Parameters:
    ///   - url: Sound file URL.
    ///   - numberOfLoops: Number of loops. Specify a negative number for an infinite loop. Default value of 0 means that the sound will be played once.
    /// - Returns: If the sound was played successfully the return value will be true. It will be false if sounds are disabled or if system could not play the sound.
    @discardableResult public static func play(url: URL, numberOfLoops: Int = 0) -> Bool {
        if !Sound.enabled {
            return false
        }
        var sound = sounds[url]
        if sound == nil {
            sound = Sound(url: url)
            sounds[url] = sound
        }
        return sound?.play(numberOfLoops: numberOfLoops) ?? false
    }

    /// Stop playing sound for given URL.
    ///
    /// - Parameter url: Sound file URL.
    public static func stop(for url: URL) {
        let sound = sounds[url]
        sound?.stop()
    }

    /// Duration of the sound.
    public var duration: TimeInterval {
        players[counter].duration
    }

    /// Sound volume.
    /// A value in the range 0.0 to 1.0, with 0.0 representing the minimum volume and 1.0 representing the maximum volume.
    public var volume: Float {
        get {
            players[counter].volume
        }
        set {
            volumeTimer = nil
            for player in players {
                player.volume = newValue
            }
        }
    }

    public func setVolume(_ value: Float, fadeDuration duration: TimeInterval) {
        for player in players {
            player.setVolume(value, fadeDuration: duration)
        }
    }

    public var rate: Float {
        get {
            players[counter].rate
        }
        set {
            for player in players {
                player.rate = rate
            }
        }
    }

    /// Stop playing sound for given sound file.
    ///
    /// - Parameters:
    ///   - file: Sound file name.
    ///   - fileExtension: Sound file extension.
    public static func stop(file: String, fileExtension: String? = nil) {
        if let url = url(for: file, fileExtension: fileExtension) {
            let sound = sounds[url]
            sound?.stop()
        }
    }

    /// Stop playing all sounds.
    public static func stopAll() {
        NotificationCenter.default.post(name: stopNotificationName, object: nil)
    }

    // MARK: - Private helper method

    private static func url(for file: String, fileExtension: String? = nil) -> URL? {
        soundsBundle.url(forResource: file, withExtension: fileExtension)
    }
}

// MARK: - Player

/// Player protocol. It duplicates `AVAudioPlayer` methods.
public protocol Player: AnyObject {
    /// Play the sound.
    ///
    /// - Parameters:
    ///   - numberOfLoops: Number of loops.
    ///   - completion: Complation handler.
    /// - Returns: true if the sound was played successfully. False otherwise.
    func play(numberOfLoops: Int, completion: PlayerCompletion?) -> Bool

    /// Stop playing the sound.
    func stop()

    /// Pause current playback.
    func pause()

    /// Resume playing.
    func resume()

    /// Reset to begin
    func reset()

    /// Prepare the sound.
    func prepareToPlay() -> Bool

    /// Create a Player for sound url.
    ///
    /// - Parameter url: sound url.
    init(contentsOf url: URL) throws

    /// - Parameter url: sound url.
    init(data: Data, fileTypeHint: String?) throws

    /// Duration of the sound.
    var duration: TimeInterval { get }

    /// Sound volume.
    var volume: Float { get set }
    func setVolume(_ volume: Float, fadeDuration duration: TimeInterval)

    /// Sound Rate.
    var rate: Float { get set }

    /// Indicates if the player is currently playing.
    var isPlaying: Bool { get }
}

public typealias PlayerCompletion = (Bool) -> Void

// MARK: - AVAudioPlayer + Player, AVAudioPlayerDelegate

private var associatedCallbackKey = "com.moonlightapps.SwiftySound.associatedCallbackKey"

extension AVAudioPlayer {
    var playerCompletion: PlayerCompletion? {
        get {
            objc_getAssociatedObject(self, &associatedCallbackKey) as? PlayerCompletion
        }
        set {
            objc_setAssociatedObject(self, &associatedCallbackKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
}

// MARK: - AVAudioPlayer + Player, AVAudioPlayerDelegate

extension AVAudioPlayer: Player, AVAudioPlayerDelegate {
    public func play(numberOfLoops: Int, completion: PlayerCompletion?) -> Bool {
        if let cmpl = completion {
            playerCompletion = cmpl
            delegate = self
        }
        self.numberOfLoops = numberOfLoops
        prepareToPlay()
        return play()
    }

    public func resume() {
        play()
    }

    public func reset() {
        pause()
        playerCompletion = nil
        currentTime = 0
        prepareToPlay()
    }

    public func audioPlayerDidFinishPlaying(_: AVAudioPlayer, successfully flag: Bool) {
        playerCompletion?(flag)
        objc_removeAssociatedObjects(self)
        delegate = nil
    }

    public func audioPlayerDecodeErrorDidOccur(_: AVAudioPlayer, error: Error?) {
        Logger.shared.error("SwiftySound playback error: \(String(describing: error))")
    }
}

#if os(iOS) || os(tvOS)
    /// Session protocol. It duplicates `setCategory` method of `AVAudioSession` class.
    public protocol Session: AnyObject {
        /// Set category for session.
        ///
        /// - Parameter category: category.
        func setCategory(_ category: AVAudioSession.Category) throws
    }

    extension AVAudioSession: Session {}
#endif
