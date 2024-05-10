//
//  AppSerivce.swift
//
//  Created by MK on 2021/8/30.
//

import Foundation
import UIKit

// MARK: - AppSerivce

public protocol AppSerivce {
    func initBeforeWindow()
    func initAfterWindow(window: UIWindow)
    func onExit()

    func onBackground()
    func onForeground()
}

public extension AppSerivce {
    func initBeforeWindow() {}
    func initAfterWindow(window _: UIWindow) {}
    func onBackground() {}
    func onForeground() {}
    func onExit() {}
}

// MARK: - AppServiceManager

public class AppServiceManager {
    public private(set) var services = [AppSerivce]()

    public init() {}

    public func addAppService(_ service: AppSerivce) {
        services.append(service)
    }

    public func findService<T: AppSerivce>(_: T.Type = T.self) -> T? {
        for service in services {
            if let service = service as? T {
                return service
            }
        }
        return nil
    }
}
