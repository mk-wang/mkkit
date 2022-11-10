//
//  UIApplicationExt.swift
//  YogaWorkout
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

    @discardableResult func rateApp(appleId: String, completion: ((Bool) -> Void)? = nil) -> Bool {
        let url = URL(string: "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appleId)")!
        return openURL(url, completion: completion)
    }

    @discardableResult func openAppSetting(completion: ((Bool) -> Void)? = nil) -> Bool {
        openURL(URL(string: UIApplication.openSettingsURLString), completion: completion)
    }

    @discardableResult func openApp(appleId: String, writeReview: Bool = false, completion: ((Bool) -> Void)? = nil) -> Bool {
        var urlStr = "https://apps.apple.com/app/id\(appleId)"
        if writeReview {
            urlStr += "?action=write-review"
        }
        let url = URL(string: urlStr)
        return openURL(url, completion: completion)
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
