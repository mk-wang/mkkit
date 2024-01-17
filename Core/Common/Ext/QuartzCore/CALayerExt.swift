//
//  CALayerExt.swift
//
//
//  Created by MK on 2022/6/28.
//

import OpenCombine
import UIKit

// MARK: - CALayer.ShadowConfig

public extension CALayer {
    struct ShadowConfig {
        let color: UIColor
        let opacity: Float?
        let offset: CGSize?
        let radius: CGFloat?
        let path: UIBezierPath?

        public init(color: UIColor, opacity: Float? = nil, offset: CGSize? = nil, radius: CGFloat? = nil, path: UIBezierPath? = nil) {
            self.color = color
            self.opacity = opacity
            self.offset = offset
            self.radius = radius
            self.path = path
        }
    }

    func applyShadowConfig(_ config: ShadowConfig) {
        shadowColor = config.color.cgColor

        if let value = config.opacity {
            shadowOpacity = value
        }
        if let value = config.offset {
            shadowOffset = value
        }
        if let value = config.radius {
            shadowRadius = value
        }
        if let value = config.path?.cgPath {
            shadowPath = value
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
        setAssociatedObject(key, color, .OBJC_ASSOCIATION_RETAIN)
    }
}

public extension CALayer {
    func pause() {
        let pausedTime: CFTimeInterval = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pausedTime
    }

    func resume() {
        let pausedTime: CFTimeInterval = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let timeSincePause: CFTimeInterval = convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        beginTime = timeSincePause
    }
}

//  Pause animations of layer tree
//
//  Technical Q&A QA1673:
//  https://developer.apple.com/library/content/qa/qa1673/_index.html#//apple_ref/doc/uid/DTS40010053
//  Persistent CoreAnimations extension
//  https://stackoverflow.com/questions/7568567/restoring-animation-where-it-left-off-when-app-resumes-from-background

public extension CALayer {
    var isAnimationsPaused: Bool {
        speed == 0.0
    }

    func pauseAnimations() {
        if !isAnimationsPaused {
            let currentTime = CACurrentMediaTime()
            let pausedTime = convertTime(currentTime, from: nil)
            speed = 0.0
            timeOffset = pausedTime
        }
    }

    func resumeAnimations() {
        let pausedTime = timeOffset
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        let currentTime = CACurrentMediaTime()
        let timeSincePause = convertTime(currentTime, from: nil) - pausedTime
        beginTime = timeSincePause
    }

    func makeAnimationsPersistent() {
        var object = objc_getAssociatedObject(self, &AssociatedKeys.persistentHelperKey)
        if object == nil {
            object = LayerPersistentHelper(with: self)
            let nonatomic = objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC
            objc_setAssociatedObject(self, &AssociatedKeys.persistentHelperKey, object, nonatomic)
        }
    }
}

// MARK: - LayerPersistentHelper

private class LayerPersistentHelper {
    private var persistentAnimations: [String: CAAnimation] = [:]
    private var persistentSpeed: Float = 0.0
    private weak var layer: CALayer?

    public init(with layer: CALayer) {
        self.layer = layer
        addNotificationObservers()
    }

    deinit {
        removeNotificationObservers()
    }
}

private extension LayerPersistentHelper {
    func addNotificationObservers() {
        let center = NotificationCenter.default
        let enterForeground = UIApplication.willEnterForegroundNotification
        let enterBackground = UIApplication.didEnterBackgroundNotification
        center.addObserver(self, selector: #selector(didBecomeActive), name: enterForeground, object: nil)
        center.addObserver(self, selector: #selector(willResignActive), name: enterBackground, object: nil)
    }

    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    func persistAnimations(with keys: [String]?) {
        guard let layer else { return }
        keys?.forEach { key in
            if let animation = layer.animation(forKey: key) {
                persistentAnimations[key] = animation
            }
        }
    }

    func restoreAnimations(with keys: [String]?) {
        guard let layer else { return }
        keys?.forEach { key in
            if let animation = persistentAnimations[key] {
                layer.add(animation, forKey: key)
            }
        }
    }
}

@objc extension LayerPersistentHelper {
    func didBecomeActive() {
        guard let layer else { return }
        restoreAnimations(with: Array(persistentAnimations.keys))
        persistentAnimations.removeAll()
        if persistentSpeed == 1.0 { // if layer was playing before background, resume it
            layer.resumeAnimations()
        }
    }

    func willResignActive() {
        guard let layer else { return }
        persistentSpeed = layer.speed
        layer.speed = 1.0 // in case layer was paused from outside, set speed to 1.0 to get all animations
        persistAnimations(with: layer.animationKeys())
        layer.speed = persistentSpeed // restore original speed
        layer.pauseAnimations()
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var backgroundColor = 0
    static var borderColor = 0
    static var shadowColor = 0
    static var persistentHelperKey = 0
}
