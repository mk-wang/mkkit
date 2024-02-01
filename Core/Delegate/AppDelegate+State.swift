//
//  AppDelegate+State.swift
//  FaceYoga
//
//  Created by MK on 2023/3/13.
//

import UIKit

// Life Cycle
extension AppDelegate {
    open func applicationWillResignActive(_ application: UIApplication) {
        // 有些系统 applicationState 可能还是 acitve，所以强制设一下
        refreshState(application, inActive: true)
    }

    open func applicationDidBecomeActive(_ application: UIApplication) {
        refreshState(application)
    }

    open func applicationWillEnterForeground(_ application: UIApplication) {
        refreshState(application)
    }

    open func applicationDidEnterBackground(_ application: UIApplication) {
        refreshState(application)
    }

    open func applicationWillTerminate(_ application: UIApplication) {
        BackgroundTask.run(application: application) { [weak self] completion in
            self?.onTerminate(application)
            completion()
        }
    }
}

// MARK: - UIApplication.State + CustomStringConvertible

extension UIApplication.State: CustomStringConvertible {
    public var description: String {
        switch self {
        case .active:
            return "active"
        case .inactive:
            return "inactive"
        case .background:
            return "background"
        @unknown default:
            return "unknown"
        }
    }
}
