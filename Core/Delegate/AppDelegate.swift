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
    public lazy var rootControllerPublisher = rootControllerSubject.eraseToAnyPublisher()

    private lazy var appStateSubject: CurrentValueSubject<AppDelegate.State, Never> = .init(.none)
    public lazy var appStatePublisher = appStateSubject.filter { $0 != .none }.eraseToAnyPublisher()

    // app 是否处于 isActive 状态，不包含第一次 app 启动
    public lazy var isActivePublisher: AnyPublisher<Bool, Never> = appStatePublisher
        .map(\.isActive)
        .removeDuplicatesAndDrop()
        .eraseToAnyPublisher()

    // app 处于 active 状态，不包含第一次 app 启动
    public lazy var appActivePublisher: AnyPublisher<Void, Never> = isActivePublisher
        .removeDuplicatesAndDrop()
        .compactMap { $0 ? () : nil }
        .eraseToAnyPublisher()

    // app 是否处于 foreground 状态，不包含第一次 app 启动
    public lazy var isForegroundPublisher: AnyPublisher<Bool, Never> = appStateSubject
        .compactMap {
            switch $0 {
            case .background:
                false
            case .foreground:
                true
            default:
                nil
            }
        }
        .removeDuplicates()
        .eraseToAnyPublisher()

    // app 处于 foreground 状态，不包含第一次 app 启动
    public lazy var appForegroundPublisher: AnyPublisher<Void, Never> = isForegroundPublisher
        .compactMap { $0 ? () : nil }
        .eraseToAnyPublisher()

    open func application(_ application: UIApplication,
                          didFinishLaunchingWithOptions opts: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        beforeWindow(application)

        window = UIWindow(frame: UIScreen.main.bounds)
        setupWindow(window: window!)

        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }
            afterWindow(application, window: window!, launchOptions: opts)
        }

        return true
    }
}

// MARK: - UIApplication.State + CustomStringConvertible

extension AppDelegate {
    public var state: AppDelegate.State {
        appStateSubject.value
    }

    open func refreshActiveState(_: UIApplication, state: AppDelegate.State) {
        appStateSubject.send(state)
    }

    @objc open var rootController: UIViewController? {
        get {
            rootControllerSubject.value
        }
        set {
            window?.rootViewController = newValue
            rootControllerSubject.value = newValue
        }
    }
}
