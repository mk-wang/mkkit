//
//  Logger+Console.swift
//  MKKit
//
//  Created by MK on 2023/8/29.
//

import Foundation

public extension Logger {
    #if DEBUG_BUILD
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

        func console(_ text: String, tag: String) {
            guard Self.showConsole.kvValue else {
                return
            }
            Self.console.print("\(tag): \(text)")
        }
    #endif

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
            #if DEBUG_BUILD
                Self.adConsole.kvValue
            #else
                nil
            #endif
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
            #if DEBUG_BUILD
                Self.trackConsole.kvValue
            #else
                nil
            #endif
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
            #if DEBUG_BUILD
                Self.ttsConsole.kvValue
            #else
                nil
            #endif
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
            #if DEBUG_BUILD
                Self.iapConsole.kvValue
            #else
                nil
            #endif
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
            #if DEBUG_BUILD
                Self.tpaConsole.kvValue
            #else
                nil
            #endif
        }
    }

    func printWithConsole(_ text: String,
                          tag: String,
                          level: Level = .debug,
                          function: String,
                          file: String,
                          line: UInt,
                          check: ValueBuilder<Bool?>)
    {
        log(level: level, message: { text }, tag: tag, function: function, file: file, line: line)

        #if DEBUG_BUILD
            guard check() ?? false else {
                return
            }

            console(text, tag: tag)
        #endif
    }
}
