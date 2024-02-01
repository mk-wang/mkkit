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

        // task will be retain by beginBackgroundTask
        public func begin() {
            guard let application, identifier == .invalid else {
                return
            }

            identifier = application.beginBackgroundTask {
                self.end()
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

    // The handler should call TaskCompletion when it is done
    @discardableResult
    class func run(application: UIApplication,
                   handler: (@escaping TaskCompletion) -> Void) -> AppDelegate.BackgroundTask
    {
        let task = AppDelegate.BackgroundTask(application: application)
        task.begin()

        handler { [weak task] in
            task?.end()
        }

        return task
    }
}
