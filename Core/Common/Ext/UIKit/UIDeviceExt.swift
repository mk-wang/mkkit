//
//  UIDeviceExt.swift
//
//
//  Created by MK on 2021/7/22.
//

import UIKit

public extension UIDevice {
    func toOrientation(orientation: UIInterfaceOrientation) {
        setValue(orientation.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }
}

public extension UIDevice {
    func isIPhone() -> Bool {
        userInterfaceIdiom == .phone
    }

    func isIPad() -> Bool {
        userInterfaceIdiom == .pad
    }
}

public extension UIDevice {
    static let modelIdentifier: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()
}
