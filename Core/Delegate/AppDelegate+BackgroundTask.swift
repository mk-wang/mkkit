//
//  AppDelegate+BackgroundTask.swift
//  MKKit
//
//  Created by MK on 2024/2/1.
//

import Foundation
import UIKit

// MARK: - AppDelegate.BackgroundTask

extension AppDelegate {
    open class BackgroundTask {
        private weak var application: UIApplication?
        private var identifier: UIBackgroundTaskIdentifier = .invalid

        public init(application: UIApplication) {
            self.application = application
        }

        public func begin() {
            guard let application else {
                return
            }

            identifier = application.beginBackgroundTask { [weak self] in
                self?.end()
            }
        }

        public func end() {
            guard let application, identifier != .invalid else {
                return
            }
            application.endBackgroundTask(identifier)
            identifier = .invalid
        }

        deinit {
            Logger.shared.debug("BackgroundTask deinit")
        }
    }
}

public extension AppDelegate.BackgroundTask {
    typealias TaskCompletion = () -> Void

    // The handler must call TaskCompletion when it is done
    // task retained by TaskCompletion
    @discardableResult
    class func run(application: UIApplication,
                   handler: (@escaping TaskCompletion) -> Void) -> AppDelegate.BackgroundTask
    {
        let task = AppDelegate.BackgroundTask(application: application)
        task.begin()

        handler {
            task.end()
        }

        return task
    }
}
