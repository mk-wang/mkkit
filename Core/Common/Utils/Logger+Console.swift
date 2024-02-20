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

        @KVStorageProperty(key: "debug.logs.tpa", storage: UserDefaultsStorage())
        private(set) static var tpaConsole: Bool = true

        @KVStorageProperty(key: "debug.logs.tts", storage: UserDefaultsStorage())
        private(set) static var ttsConsole: Bool = true

        @KVStorageProperty(key: "debug.logs.iap", storage: UserDefaultsStorage())
        private(set) static var iapConsole: Bool = true

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

        func ad(_ text: String,
                function: String = #function,
                file: String = #file,
                line: UInt = #line)
        {
            printWithConsole(text, tag: "ad",
                             function: function,
                             file: file,
                             line: line)
            {
                Self.adConsole.kvValue
            }
        }

        func track(_ text: String,
                   function: String = #function,
                   file: String = #file,
                   line: UInt = #line)
        {
            printWithConsole(text, tag: "track",
                             function: function,
                             file: file,
                             line: line)
            {
                Self.trackConsole.kvValue
            }
        }

        func tts(_ text: String,
                 function: String = #function,
                 file: String = #file,
                 line: UInt = #line)
        {
            printWithConsole(text, tag: "tts",
                             function: function,
                             file: file,
                             line: line)
            {
                Self.ttsConsole.kvValue
            }
        }

        func iap(_ text: String,
                 function: String = #function,
                 file: String = #file,
                 line: UInt = #line)
        {
            printWithConsole(text, tag: "iap",
                             level: .info,
                             function: function,
                             file: file,
                             line: line)
            {
                Self.iapConsole.kvValue
            }
        }

        func tpa(_ text: String,
                 function: String = #function,
                 file: String = #file,
                 line: UInt = #line)
        {
            printWithConsole(text, tag: "tpa",
                             function: function,
                             file: file,
                             line: line)
            {
                Self.tpaConsole.kvValue
            }
        }

        func printWithConsole(_ text: String,
                              tag: String,
                              level: Level = .debug,
                              function: String,
                              file: String,
                              line: UInt,
                              check: ValueBuilder<Bool>)
        {
            log(level: level, message: text, tag: tag, function: function, file: file, line: line)

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
        func iap(_: String) {}
        func debugWithConsole(_: String, tag _: String, check _: ValueBuilder<Bool>) {}
        func console(_: String, tag _: String) {}
    }
#endif
