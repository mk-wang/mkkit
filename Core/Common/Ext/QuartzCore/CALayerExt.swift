//
//  CALayerExt.swift
//
//
//  Created by MK on 2022/6/28.
//

import OpenCombine
import UIKit

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
        setAssociatedObject(key, color, .OBJC_ASSOCIATION_RETAIN)
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var backgroundColor = 0
    static var borderColor = 0
    static var shadowColor = 0
}
