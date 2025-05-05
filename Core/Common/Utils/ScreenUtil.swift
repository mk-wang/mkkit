//
//  ScreenUtil.swift
//
//
//  Created by MK on 2021/6/4.
//

import UIKit

// MARK: - ScreenUtil

@objc public class ScreenUtil: NSObject {
    @objc public static let screenSize: CGSize = UIScreen.main.bounds.size
    @objc public static let screenMin = min(screenSize.width, screenSize.height)
    @objc public static let screenMax = max(screenSize.width, screenSize.height)

    @objc public static let isSmall = screenMin < 321
    @objc public static let isFlat = !hasNotch || hwRatio < 1.8

    @objc public static let scale = UIScreen.main.scale
    @objc public static let hwRatio = screenSize.height / screenSize.width

    @objc public private(set) static var ratio: CGPoint = .zero
    @objc public private(set) static var minRatio: CGFloat = 0
}

public extension ScreenUtil {
    internal private(set) static var designSize: CGSize = .zero {
        didSet {
            ratio.x = screenSize.width / designSize.width
            ratio.y = screenSize.height / designSize.height

            minRatio = min(ratio.x, ratio.y)
        }
    }

    @objc private(set) static var window: UIWindow!

    @objc static var rootViewController: UIViewController? {
        window.rootViewController
    }

    @objc static func setup(window: UIWindow, designSize: CGSize) {
        self.window = window
        self.designSize = designSize
    }
}

public extension ScreenUtil {
    @objc static func float(_ normal: CGFloat, flat: CGFloat) -> CGFloat {
        isFlat ? flat : normal
    }

    @objc static func float(_ normal: CGFloat, small: CGFloat) -> CGFloat {
        isSmall ? small : normal
    }

    @objc static func float(_ normal: CGFloat, small: CGFloat, flat: CGFloat) -> CGFloat {
        isSmall ? small : (isFlat ? flat : normal)
    }
}

public extension ScreenUtil {
    @objc static let navBarHeight: CGFloat = UINavigationBar().intrinsicContentSize.height

    private static var _statusBarSize: CGSize?

    @objc static var statusBarWidth: CGFloat {
        statusBarSize.width
    }

    @objc static var statusBarHeight: CGFloat {
        statusBarSize.height
    }

    @objc static var statusBarSize: CGSize {
        if let _statusBarSize {
            return _statusBarSize
        }

        var size: CGSize?
        if #available(iOS 13.0, *), let scene = window?.windowScene {
            size = scene.statusBarManager?.statusBarFrame.size
        }

        if size == nil || size!.height == 0 {
            size = UIApplication.shared.statusBarFrame.size
        }

        if let size, size.height > 0 {
            _statusBarSize = size
        }
        return _statusBarSize ?? .zero
    }

    @objc static var windowOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            self.window?.windowScene?.interfaceOrientation ?? .unknown
        } else {
            UIApplication.shared.statusBarOrientation
        }
    }

    @objc static var hasNotch: Bool {
        topSafeArea > 20
    }

    @objc static var topSafeArea: CGFloat {
        safeAreaInsets.top
    }

    @objc static var bottomSafeArea: CGFloat {
        safeAreaInsets.bottom
    }

    private static var _safeAreaInsets: UIEdgeInsets?
    @objc static var safeAreaInsets: UIEdgeInsets {
        if let _safeAreaInsets {
            return _safeAreaInsets
        }

        var insets = window.safeAreaInsets
        if insets == .zero, let rootView = window.rootViewController?.view {
            insets = rootView.safeAreaInsets
        }
        if insets == .zero {
            insets = .only(top: statusBarHeight)
        } else {
            _safeAreaInsets = insets
        }
        return insets
    }

    @objc static let isPad = UIDevice.current.userInterfaceIdiom == .pad
    @objc static let isPhone = UIDevice.current.userInterfaceIdiom == .phone
    @objc static var isLandscape: Bool {
        UIDevice.current.orientation.isLandscape
    }
}

public extension ScreenUtil {
    static func topHeightAddition(notch h1: CGFloat, normal h2: CGFloat) -> CGFloat {
        (hasNotch ? h1 : h2) + topSafeArea
    }

    static func bottomHeight(safeArea h1: CGFloat, normal h2: CGFloat) -> CGFloat {
        bottomSafeArea > 1 ? h1 : h2
    }

    static func bottomSafeAreaOr(height: CGFloat) -> CGFloat {
        bottomHeight(safeArea: bottomSafeArea, normal: height)
    }

    static func bottomSafeAreaMax(height: CGFloat) -> CGFloat {
        max(bottomSafeArea, height)
    }

    static func bottomHeight(safeAreaAddition h1: CGFloat, normal h2: CGFloat? = nil) -> CGFloat {
        bottomSafeArea > 1 ? bottomSafeArea + h1 : (h2 ?? h1)
    }
}

public extension MKFloatingPoint {
    var rw: CGFloat {
        ScreenUtil.ratio.x * cgfValue
    }

    var rh: CGFloat {
        ScreenUtil.ratio.y * cgfValue
    }

    var rs: CGFloat {
        ScreenUtil.minRatio * cgfValue
    }

    var rwMin: CGFloat {
        let value = cgfValue
        return min(value, value.rw)
    }

    var rwMax: CGFloat {
        let value = cgfValue
        return max(value, value.rw)
    }

    var rhMin: CGFloat {
        let value = cgfValue
        return min(value, value.rh)
    }

    var rhMax: CGFloat {
        let value = cgfValue
        return max(value, value.rh)
    }

    var rwsMin: CGFloat {
        let val = cgfValue
        if ScreenUtil.isSmall {
            return val
        }
        return rwMin
    }

    var rwsMax: CGFloat {
        let val = cgfValue
        if ScreenUtil.isSmall {
            return val
        }
        return rwMax
    }

    var rhsMin: CGFloat {
        let val = cgfValue
        if ScreenUtil.isSmall {
            return val
        }
        return rhMin
    }

    var rhsMax: CGFloat {
        let val = cgfValue
        if ScreenUtil.isSmall {
            return val
        }
        return rhMax
    }
}

public extension CGSize {
    var rw: Self {
        let scale = ScreenUtil.ratio.x
        return .init(width: width * scale, height: height * scale)
    }

    var rh: Self {
        let scale = ScreenUtil.ratio.y
        return .init(width: width * scale, height: height * scale)
    }
}

public extension CGPoint {
    var rw: Self {
        let scale = ScreenUtil.ratio.x
        return .init(x: x * scale, y: y * scale)
    }

    var rh: Self {
        let scale = ScreenUtil.ratio.y
        return .init(x: x * scale, y: y * scale)
    }
}

public extension UIEdgeInsets {
    var rw: Self {
        let scale = ScreenUtil.ratio.x
        return .init(top: top * scale,
                     left: left * scale,
                     bottom: bottom * scale,
                     right: right * scale)
    }

    var rh: Self {
        let scale = ScreenUtil.ratio.y
        return .init(top: top * scale,
                     left: left * scale,
                     bottom: bottom * scale,
                     right: right * scale)
    }
}
