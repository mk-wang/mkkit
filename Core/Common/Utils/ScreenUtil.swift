//
//  ScreenUtil.swift
//
//
//  Created by MK on 2021/6/4.
//

import UIKit

// MARK: - ScreenUtil

public enum ScreenUtil {
    public static let screenSize: CGSize = UIScreen.main.bounds.size
    public static let screenMin = min(screenSize.width, screenSize.height)
    public static let screenMax = max(screenSize.width, screenSize.height)

    public static let isSmall = screenMin < 321
    public static let isFlat = !hasNotch || hwRatio < 1.8

    public static let scale = UIScreen.main.scale
    public static let hwRatio = screenSize.height / screenSize.width

    private(set) static var ratio: CGPoint = .zero
    private(set) static var minRatio: CGFloat = 0
}

public extension ScreenUtil {
    internal private(set) static var designSize: CGSize = .zero {
        didSet {
            ratio.x = screenSize.width / designSize.width
            ratio.y = screenSize.height / designSize.height

            minRatio = min(ratio.x, ratio.y)
        }
    }

    private(set) static var window: UIWindow!

    static var rootViewController: UIViewController? {
        window.rootViewController
    }

    static func setup(window: UIWindow, designSize: CGSize) {
        self.window = window
        self.designSize = designSize
    }
}

public extension ScreenUtil {
    static let navBarHeight: CGFloat = UINavigationBar().intrinsicContentSize.height

    static var statusBarHeight: CGFloat {
        var height: CGFloat?

        if #available(iOS 13.0, *) {
            if let scene = window.windowScene {
                height = scene.statusBarManager?.statusBarFrame.size.height
            }
        }

        return height ?? UIApplication.shared.statusBarFrame.size.height
    }

    static var windowOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            return self.window?.windowScene?.interfaceOrientation ?? .unknown
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }

    static var hasNotch: Bool {
        topSafeArea > 20
    }

    static var topSafeArea: CGFloat {
        safeAreaInsets.top
    }

    static var bottomSafeArea: CGFloat {
        safeAreaInsets.bottom
    }

    static var safeAreaInsets: UIEdgeInsets {
        var insets = window.safeAreaInsets
        if insets == .zero, let rootView = window.rootViewController?.view {
            insets = rootView.safeAreaInsets
        }
        return insets
    }

    static let isPad = UIDevice.current.userInterfaceIdiom == .pad

    static var isLandscape: Bool {
        UIDevice.current.orientation.isLandscape
    }
}

public extension ScreenUtil {
//    static func topHeight(safeArea h1: CGFloat, normal h2: CGFloat) -> CGFloat {
//        hasNotch ? h1 : h2
//    }
//
//    static func topSafeAreaOr(height: CGFloat) -> CGFloat {
//        topHeight(safeArea: topSafeArea, normal: height)
//    }
//
//    static func topSafeAreaMax(height: CGFloat) -> CGFloat {
//        max(topSafeArea, height)
//    }

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
        CGFloat.minimum(CGFloat(1), ScreenUtil.ratio.x) * cgfValue
    }

    var rwMax: CGFloat {
        CGFloat.maximum(CGFloat(1), ScreenUtil.ratio.x) * cgfValue
    }

    var rhMin: CGFloat {
        CGFloat.minimum(CGFloat(1), ScreenUtil.ratio.y) * cgfValue
    }

    var rhMax: CGFloat {
        CGFloat.maximum(CGFloat(1), ScreenUtil.ratio.y) * cgfValue
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
}

public extension CGPoint {
    var rw: Self {
        let scale = ScreenUtil.ratio.x
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
}
