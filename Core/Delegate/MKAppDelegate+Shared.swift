//
//  MKAppDelegate+Shared.swift
//
//  Created by MK on 2021/6/11.
//

import MKKit
import OpenCombine
import UIKit

extension MKAppDelegate {
    public static let shared = UIApplication.shared.delegate as? MKAppDelegate

    @objc open func beforeWindow(_: UIApplication) {}

    @objc open func setupWindow(window _: UIWindow) {}

    @objc open func afterWindow(_: UIApplication,
                                window _: UIWindow,
                                launchOptions _:
                                [UIApplication.LaunchOptionsKey: Any]?)
    {}

    @objc open func onTerminate(_: UIApplication,
                                completion: @escaping BackgroundTask.TaskCompletion)
    {
        completion()
    }
}
