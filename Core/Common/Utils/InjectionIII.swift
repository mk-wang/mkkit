//
//  InjectionIII.swift
//
//
//  Created by MK on 2022/3/16.
//

import Foundation
import UIKit

private var bundleLoaded = false

public extension UIApplicationDelegate {
    func loadInjection(appPath: String) {
        #if DEBUG
            #if os(macOS)
                let bundleName = "macOSInjection.bundle"
            #elseif os(tvOS)
                let bundleName = "tvOSInjection.bundle"
            #elseif targetEnvironment(simulator)
                let bundleName = "iOSInjection.bundle"
            #else
                let bundleName = "maciOSInjection.bundle"
            #endif
            bundleLoaded = Bundle(path: "\(appPath)/Contents/Resources/" + bundleName)?.load() ?? false
        #endif
    }
}

// MARK: - InjectionIII

public protocol InjectionIII {
    typealias Injection = () -> Void

    func addInjection(injection: @escaping Injection)
}

public extension InjectionIII where Self: UIResponder {
    func addInjection(injection: @escaping Injection) {
        #if DEBUG
            guard bundleLoaded else {
                return
            }
            injections.add(injection)

            if injectionNoteCancellable == nil {
                injectionNoteCancellable = notificationCenter
                    .publisher(for: Notification.Name("INJECTION_BUNDLE_NOTIFICATION"))
                    .removeDuplicates()
                    .debounceOnMain(for: 0.3)
                    .sink(receiveValue: { [weak injections] _ in
                        injections?.forEach { element in
                            if let cb = element as? Injection {
                                cb()
                            }
                        }
                    })
            }
        #endif
    }
}

private extension NSObject {
    var injections: NSMutableArray {
        get {
            if let list = getAssociatedObject(&AssociatedKeys.kInjecntions) as? NSMutableArray {
                return list
            }
            let list = NSMutableArray()
            self.injections = list
            return list
        }
        set {
            setAssociatedObject(&AssociatedKeys.kInjecntions, newValue)
        }
    }

    var injectionNoteCancellable: AnyCancellableType? {
        get {
            getAssociatedObject(&AssociatedKeys.kCancellable) as? AnyCancellableType
        }
        set {
            setAssociatedObject(&AssociatedKeys.kCancellable, newValue)
        }
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kInjecntions = 0
    static var kCancellable = 0
}
