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

        func console(_ text: String, tag: String) {
            guard Self.showConsole.kvValue else {
                return
            }
            Self.console.print("\(tag): \(text)")
        }

        func ad(_ text: String) {
            let tag = "ad"
            debug(text, tag: tag)
            guard Self.adConsole.kvValue else {
                return
            }
            console(text, tag: "ad")
        }

        func track(_ text: String) {
            let tag = "track"
            debug(tag)

            guard Self.trackConsole.kvValue else {
                return
            }

            console(text, tag: tag)
        }
    }

#else
    public extension Logger {
        static func setupConsole() {}
        func console(_: String, tag _: String) {}
        func ad(_: String) {}
        func track(_: String) {}
    }
#endif
