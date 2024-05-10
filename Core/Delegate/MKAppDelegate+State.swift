//
//  MKAppDelegate+State.swift
//
//  Created by MK on 2023/3/13.
//

import UIKit

// MARK: - MKAppDelegate.State

public extension MKAppDelegate {
    enum State: Int {
        case none = -1
        case active = 0
        case inactive
        case background
        case foreground
        case terminate

        var isActive: Bool {
            self == .foreground || self == .active
        }
    }
}

// Life Cycle
extension MKAppDelegate {
    open func applicationWillResignActive(_ application: UIApplication) {
        refreshActiveState(application, state: .inactive)
    }

    open func applicationDidBecomeActive(_ application: UIApplication) {
        refreshActiveState(application, state: .active)
    }

    open func applicationWillEnterForeground(_ application: UIApplication) {
        refreshActiveState(application, state: .foreground)

        for service in appServices {
            service.onForeground()
        }
    }

    open func applicationDidEnterBackground(_ application: UIApplication) {
        refreshActiveState(application, state: .background)

        for service in appServices {
            service.onBackground()
        }
    }

    open func applicationWillTerminate(_ application: UIApplication) {
        refreshActiveState(application, state: .terminate)

        BackgroundTask.run(application: application) { [weak self] completion in
            guard let self else {
                return
            }

            if let window {
                for service in appServices {
                    service.onExit()
                }
            }

            onTerminate(application, completion: completion)
        }
    }
}
