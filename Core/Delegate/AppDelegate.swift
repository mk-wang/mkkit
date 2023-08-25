//
//  AppDelegate.swift
//
//  Created by MK on 2022/3/16.
//

import MKKit
import OpenCombine
import UIKit

// MARK: - AppDelegate

open class AppDelegate: UIResponder, UIApplicationDelegate {
    public var window: UIWindow?

    private let rootControllerSubject = CurrentValueSubject<UIViewController?, Never>(nil)
    lazy var rootControllerPublisher = rootControllerSubject.eraseToAnyPublisher()

    private lazy var appStateSubject = CurrentValueSubject<UIApplication.State, Never>(UIApplication.shared.applicationState)

    // 不removeDuplicates ，有些手机例如 iOS 15， 再控制面板弹出的时候，状态也是 active
    public lazy var appStatePublisher: AnyPublisher<UIApplication.State, Never> = appStateSubject.eraseToAnyPublisher()

    open func application(_ application: UIApplication,
                          didFinishLaunchingWithOptions opts: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        SelfLoader.loadAll()

        beforeWindow(application)

        window = UIWindow(frame: UIScreen.main.bounds)
        setupWindow(window: window!)

        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            self.afterWindow(application, window: self.window!, launchOptions: opts)
        }
        return true
    }
}

// MARK: - UIApplication.State + CustomStringConvertible

extension AppDelegate {
    open func refreshState(_ application: UIApplication) {
        let state = application.applicationState
        appStateSubject.send(state)
    }

    open var rootController: UIViewController? {
        get {
            rootControllerSubject.value
        }
        set {
            window?.rootViewController = newValue
            rootControllerSubject.value = newValue
        }
    }
}
