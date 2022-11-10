//
//  AppThemeExt.swift
//
//
//  Created by MK on 2022/3/21.
//

import Foundation
import OpenCombine
import UIKit

extension AppTheme {
    private static var service: AppThemeService {
        AppServiceManager.findService(AppThemeService.self)!
    }

    static var current: Self {
        get {
            service.theme
        }
        set {
            service.theme = newValue
        }
    }

    static var darkPublisher: AnyPublisher<Bool?, Never> {
        service.darkPublisher
    }
}

extension AppTheme {
    var isDark: Bool? {
        switch self {
        case .light:
            return false
        case .dark:
            return true
        case .system:
            return Self.service.isDark
        }
    }
}

extension AppTheme {
    static let darkStatusBarStyle: UIStatusBarStyle = {
        var style: UIStatusBarStyle!
        if #available(iOS 13.0, *) {
            style = .darkContent
        } else {
            style = .default
        }
        return style
    }()

    static var preferredStatusBarStyle: UIStatusBarStyle {
        guard let dark = AppTheme.current.isDark else {
            return .default
        }

        return dark ? .lightContent : darkStatusBarStyle
    }
}

// MARK: - AppThemeService + AppSerivce

extension AppThemeService: AppSerivce {
    public func initBeforeWindow() {
        config()
    }

    public func initAfterWindow(window: UIWindow) {
        darkConfig(window: window)

        do {
            let appearance = UITabBarItem.appearance()
            let offset: CGFloat = window.safeAreaInsets.bottom > 0 ? -4 : -6
            appearance.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: offset)
        }
    }

    public func onExit() {}
}
