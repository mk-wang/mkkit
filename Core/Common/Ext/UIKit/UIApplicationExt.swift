//
//  UIApplicationExt.swift
//
//
//  Created by MK on 2021/5/26.
//

import UIKit

public extension UIApplication {
    static var sharedKeyWindow: UIWindow {
        let sharedApp = UIApplication.shared
        return sharedApp.keyWindow ?? ScreenUtil.window
    }
}

public extension UIApplication {
    @discardableResult func openURL(_ url: URL?, completion: ((Bool) -> Void)? = nil) -> Bool {
        guard let url, canOpenURL(url) else {
            completion?(false)
            return false
        }
        DispatchQueue.main.async {
            self.open(url, options: [:], completionHandler: completion)
        }
        return true
    }

    @discardableResult func openHealthApp(completion: ((Bool) -> Void)? = nil) -> Bool {
        openURL(URL(string: "x-apple-health://")!, completion: completion)
    }

    @discardableResult func mail(to mail: String, completion: ((Bool) -> Void)? = nil) -> Bool {
        openURL(URL(string: "mailto://\(mail)"), completion: completion)
    }

    @discardableResult func openAppSetting(completion: ((Bool) -> Void)? = nil) -> Bool {
        openURL(URL(string: UIApplication.openSettingsURLString), completion: completion)
    }

    @discardableResult func openSetting(completion: ((Bool) -> Void)? = nil) -> Bool {
        var str = "i9xdUjjRjlyzmSliin".rot(n: 6) as NSString
        str = str.replacingOccurrences(of: "X", with: "-") as NSString
        str = str.replacingOccurrences(of: "Y", with: ":") as NSString
        str = str.substring(from: 4) as NSString
        return openURL(URL(string: str as String), completion: completion)
    }

    // open App Store
    @discardableResult func openAppStore(writeReview: Bool = false, completion: ((Bool) -> Void)? = nil) -> Bool {
        openURL(writeReview ? AppInfo.reviewURL : AppInfo.downloadURL, completion: completion)
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kCanRotate = 0
}

public extension UIApplication {
    var rootController: UIViewController? {
        get {
            guard let window = delegate?.window, let window else {
                return nil
            }
            return window.rootViewController
        }
        set {
            guard let window = delegate?.window, let window else {
                return
            }
            window.rootViewController = newValue
        }
    }

    @available(iOS 13.0, *)
    static var focusedScene: UIWindowScene? {
        shared.connectedScenes
            .first { $0.activationState == .foregroundActive && $0 is UIWindowScene } as? UIWindowScene
    }
}
