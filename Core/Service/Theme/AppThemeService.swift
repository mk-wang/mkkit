//
//  AppThemeService.swift
//
//
//  Created by MK on 2022/3/21.
//

import FluentDarkModeKit
import Foundation
import OpenCombine

// MARK: - AppThemeService

public class AppThemeService {
    var cancellableSet = Set<AnyCancellable>()

    public init(themeSubject: CurrentValueSubject<AppTheme, Never>) {
        self.themeSubject = themeSubject
    }

    private let themeSubject: CurrentValueSubject<AppTheme, Never>

    private let darkSubject = CurrentValueSubject<Bool?, Never>(nil)
    public lazy var darkPublisher: AnyPublisher<Bool?, Never> = darkSubject.removeDuplicates().eraseToAnyPublisher()

    public var isDark: Bool? {
        get {
            darkSubject.value
        }

        set {
            darkSubject.value = newValue
        }
    }
}

// MARK: AppSerivce

public extension AppThemeService {
    func config() {
        let current = themeSubject.value

        DMTraitCollection.setOverride(DMTraitCollection(userInterfaceStyle: current.dmStyle),
                                      animated: false)

        let configuration = DMEnvironmentConfiguration()

        weak var weakSelf = self
        if #available(iOS 13.0, *) {
            configuration.windowThemeChangeHandler = {
                weakSelf?.darkConfig(window: $0)
            }
        } else {
            configuration.themeChangeHandler = {
                weakSelf?.darkConfig(window: nil)
            }
        }
        DarkModeManager.setup(with: configuration)
        DarkModeManager.register(with: UIApplication.shared)

        themeSubject.sink(receiveValue: { newValue in
            DMTraitCollection.setOverride(DMTraitCollection(userInterfaceStyle: newValue.dmStyle),
                                          animated: true)
        }).store(in: &cancellableSet)
    }
}

public extension AppThemeService {
    var theme: AppTheme {
        get {
            themeSubject.value
        }
        set {
            if themeSubject.value != newValue {
                themeSubject.value = newValue
            }
        }
    }
}

public extension AppThemeService {
    func darkConfig(window: UIWindow?) {
        var isDark = false
        if #available(iOS 13.0, *) {
            isDark = window!.traitCollection.userInterfaceStyle == .dark
        } else {
            let style = DMTraitCollection.override.userInterfaceStyle
            if style != .unspecified {
                isDark = style == .dark
            } else {
                // never be excuted
                isDark = AppTheme.default == .dark
            }
        }
        self.isDark = isDark
    }
}
