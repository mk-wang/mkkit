//
//  Logger+Console.swift
//  MKKit
//
//  Created by MK on 2023/8/29.
//

import Foundation
import OpenCombine

#if DEBUG_BUILD
    public extension Logger {
        private static let console: GHConsole = .shared()

        @KVStorageProperty(key: "debug.logs", storage: UserDefaultsStorage())
        private(set) static var showConsole: Bool = true

        @KVStorageProperty(key: "debug.logs.ad", storage: UserDefaultsStorage())
        private(set) static var adConsole: Bool = true

        @KVStorageProperty(key: "debug.logs.track", storage: UserDefaultsStorage())
        private(set) static var trackConsole: Bool = true

        @KVStorageProperty(key: "debug.logs.tts", storage: UserDefaultsStorage())
        private(set) static var ttsConsole: Bool = true

        private static var consoleObs: AnyCancellable?

        static func setupConsole() {
            consoleObs = $showConsole.sink { show in
                if show {
                    console.startPrintLog()
                } else {
                    console.stopPrinting()
                }
            }
        }

        func ad(_ text: String) {
            debugWithConsole(text, tag: "ad") {
                Self.adConsole.kvValue
            }
        }

        func track(_ text: String) {
            debugWithConsole(text, tag: "track") {
                Self.trackConsole.kvValue
            }
        }

        func tts(_ text: String) {
            debugWithConsole(text, tag: "tts") {
                Self.ttsConsole.kvValue
            }
        }

        func debugWithConsole(_ text: String, tag: String, check: ValueBuilder<Bool>) {
            debug(text, tag: tag)

            guard check() else {
                return
            }

            console(text, tag: tag)
        }

        func console(_ text: String, tag: String) {
            guard Self.showConsole.kvValue else {
                return
            }
            Self.console.print("\(tag): \(text)")
        }
    }
#else
    public extension Logger {
        static func setupConsole() {}
        func ad(_: String) {}
        func track(_: String) {}
        func tts(_: String) {}
        func debugWithConsole(_: String, tag _: String, check _: ValueBuilder<Bool>) {}
        func console(_: String, tag _: String) {}
    }
#endif
