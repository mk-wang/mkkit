//
//  AppServiceManager.swift
//
//
//  Created by MK on 2022/3/23.
//

import Foundation
import UIKit

// MARK: - AppServiceManager

public enum AppServiceManager {}

public extension AppServiceManager {
    internal fileprivate(set) static var appServices = [AppSerivce]()

    static func addAppService(_ service: AppSerivce) {
        appServices.append(service)
    }

    static func findService<T: AppSerivce>(_: T.Type = T.self) -> T? {
        for service in appServices {
            if let service = service as? T {
                return service
            }
        }
        return nil
    }
}

public extension AppServiceManager {
    static func beforeWindow(_: UIApplication) {
        for service in appServices {
            service.initBeforeWindow()
        }
    }

    static func afterWindow(_: UIApplication,
                            window: UIWindow,
                            launchOptions _:
                            [UIApplication.LaunchOptionsKey: Any]?)
    {
        for service in appServices {
            service.initAfterWindow(window: window)
        }
    }

    static func onTerminate(_: UIApplication) {
        for service in appServices {
            service.onExit()
        }
    }
}

extension AppServiceManager {
//    static var themeService = Self.findService(AppThemeService.self)!
}
