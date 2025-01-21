//
//  AppThemeExt.swift
//
//
//  Created by MK on 2022/3/21.
//

import Foundation
#if canImport(OpenCombine)
    import OpenCombine
#elseif canImport(Combine)
    import Combine
#endif
import UIKit

public extension AppTheme {
    private static var service: AppThemeService {
        MKAppDelegate.shared!.findService(AppThemeService.self)!
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

public extension AppTheme {
    var isDark: Bool? {
        switch self {
        case .light:
            false
        case .dark:
            true
        case .system:
            Self.service.isDark
        }
    }
}

public extension AppTheme {
    static let darkStatusBarStyle: UIStatusBarStyle = {
        var style: UIStatusBarStyle! = if #available(iOS 13.0, *) {
            .darkContent
        } else {
            .default
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
    }
}

public extension ThemeChangeListener where Self: AnyObject {
    func subjectThemeChange() -> AnyCancellable {
        AppTheme.darkPublisher.sink { [weak self] isDark in
            self?.onThemeChange(isDark: isDark ?? false)
        }
    }
}

// MARK: - AppThemeCGColor

class AppThemeCGColor: NSObject {
    let lightColorBuiler: (() -> UIColor?)?
    let darkColorBuiler: (() -> UIColor?)?
    let onThemeChange: (CGColor) -> Void

    var cancellable: AnyCancellable?

    var cgColor: CGColor = UIColor.clear.cgColor

    init(onThemeChange: @escaping (CGColor) -> Void,
         lightColorBuiler: (() -> UIColor?)? = nil,
         darkColorBuiler: (() -> UIColor?)? = nil)
    {
        self.onThemeChange = onThemeChange
        self.lightColorBuiler = lightColorBuiler
        self.darkColorBuiler = darkColorBuiler
        super.init()

        cancellable = AppTheme.darkPublisher.sink { [weak self] isDark in
            self?.onThemeChange(isDark: isDark ?? false)
        }
    }

    private func onThemeChange(isDark: Bool) {
        let builder = isDark ? darkColorBuiler : lightColorBuiler
        let uiColor: UIColor = (builder == nil ? nil : builder!()) ?? .clear
        cgColor = uiColor.cgColor
        onThemeChange(cgColor)
    }
}

extension CALayer {
    func setBackgroundThemeColor(lightColorBuiler: (() -> UIColor?)? = nil, darkColorBuiler: (() -> UIColor?)? = nil) {
        let color = AppThemeCGColor(onThemeChange: { [weak self] color in
            self?.backgroundColor = color
        }, lightColorBuiler: lightColorBuiler,
        darkColorBuiler: darkColorBuiler)
        associate(color: color, key: &AssociatedKeys.backgroundColor)
    }

    func setBorderThemeColor(lightColorBuiler: (() -> UIColor?)? = nil, darkColorBuiler: (() -> UIColor?)? = nil) {
        let color = AppThemeCGColor(onThemeChange: { [weak self] color in
            self?.borderColor = color
        }, lightColorBuiler: lightColorBuiler,
        darkColorBuiler: darkColorBuiler)
        associate(color: color, key: &AssociatedKeys.borderColor)
    }

    func setShadowThemeColor(lightColorBuiler: (() -> UIColor?)? = nil, darkColorBuiler: (() -> UIColor?)? = nil) {
        let color = AppThemeCGColor(onThemeChange: { [weak self] color in
            self?.shadowColor = color
        }, lightColorBuiler: lightColorBuiler,
        darkColorBuiler: darkColorBuiler)
        associate(color: color, key: &AssociatedKeys.shadowColor)
    }

    private func associate(color: AppThemeCGColor?, key: UnsafeRawPointer) {
        setAssociatedObject(key, color)
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var backgroundColor = 0
    static var borderColor = 0
    static var shadowColor = 0
}
