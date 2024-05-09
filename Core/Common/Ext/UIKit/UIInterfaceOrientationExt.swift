//
//  UIInterfaceOrientationExt.swift
//
//
//  Created by MK on 2021/6/22.
//

import UIKit

// MARK: - OrientationLayout

public enum OrientationLayout: UInt8 {
    case portrait
    case landscape
    case unspecified
}

public extension OrientationLayout {
    func convertByDeviceOrientation() -> UIInterfaceOrientation {
        if self == .portrait {
            return .portrait
        } else if self == .unspecified {
            return .unknown
        }

        let deviceOrientation = UIDevice.current.orientation

        if deviceOrientation == .landscapeLeft {
            return .landscapeLeft
        } else {
            return .landscapeRight
        }
    }

    static func request(to orientation: OrientationLayout) {
        let interface = orientation.convertByDeviceOrientation()
        UIInterfaceOrientation.request(to: interface)
    }
}

extension UIInterfaceOrientation {
    var toMask: UIInterfaceOrientationMask {
        switch self {
        case .portrait:
            .portrait
        case .landscapeLeft:
            .landscapeLeft
        case .landscapeRight:
            .landscapeRight
        case .portraitUpsideDown:
            .portraitUpsideDown
        default:
            .allButUpsideDown
        }
    }

    static func request(to orientation: UIInterfaceOrientation) {
        if orientation == .unknown {
            return
        }

        #if swift(>=5.7)
            if #available(iOS 16.0, *) {
                if let windowScene = ScreenUtil.window?.windowScene {
                    let mask: UIInterfaceOrientationMask = orientation.toMask
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: mask)) { _ in
                    }
                    return
                }
            }
        #endif
        UIDevice.current.toOrientation(orientation: orientation)
    }
}
