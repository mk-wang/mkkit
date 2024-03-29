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

    private lazy var appStateSubject: CurrentValueSubject<UIApplication.State, Never> = .init(UIApplication.shared.applicationState)
    public lazy var appStatePublisher = appStateSubject.eraseToAnyPublisher()

    private lazy var backgroundSubject: CurrentValueSubject<Bool, Never> = .init(false)
    public lazy var backgroundPublisher = backgroundSubject.eraseToAnyPublisher()

    public lazy var appActivedPublisher = appStateSubject.removeDuplicatesAndDrop()
        .compactMap { $0 == .active ? () : nil }
        .debounceOnMain(for: 0.01)
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
    open func refreshActiveState(_ application: UIApplication, inActive: Bool? = nil) {
        var state = application.applicationState
        if let inActive {
            state = inActive ? .inactive : .active
        }
        appStateSubject.send(state)
    }

    open func refreshBackgroundState(_: UIApplication, background: Bool) {
        backgroundSubject.send(background)
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
