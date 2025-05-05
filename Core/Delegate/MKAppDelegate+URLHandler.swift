//
//  MKAppDelegate+URLHandler.swift
//  MKKit
//
//  Created by MK on 2024/5/16.
//

import Foundation

// MARK: - MKAppURLHandler

public protocol MKAppURLHandler {
    func handle(url: URL,
                options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
}

public extension MKAppDelegate {
    func addURLHandler(_ handler: MKAppURLHandler) {
        urlHandlers.append(handler)
    }

    open func application(_: UIApplication,
                          open url: URL,
                          options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    {
        for handler in urlHandlers {
            if handler.handle(url: url, options: options) {
                return true
            }
        }

        return false
    }
}
