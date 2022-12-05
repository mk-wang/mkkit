//
//  UIViewContollerHook.swift
//
//  Created by MK on 2022/11/7.
//

import MKKit
import UIKit

// MARK: - ControllerWithFirstAppear

public protocol ControllerWithFirstAppear: UIViewController {
    func beforeViewWillAppear(first _: Bool)

    func afterViewWillAppear(first _: Bool)

    func beforeViewDidAppear(first _: Bool)

    func afterViewDidAppear(first _: Bool)
}

private extension ControllerWithFirstAppear {
    var firstAppear: FirstAppear {
        if let obj = getAssociatedObject(&AssociatedKeys.kFirstAppear) as? FirstAppear {
            return obj
        }
        let obj = FirstAppear()
        setAssociatedObject(&AssociatedKeys.kFirstAppear, obj)
        return obj
    }
}

// MARK: - FirstAppear

private class FirstAppear {
    var will = true
    var did = true
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kFirstAppear = 0
}

// MARK: - ControllerWithFirstAppearHelper

public enum ControllerWithFirstAppearHelper {
    typealias ClosureType = @convention(c) (UIViewController, Selector, Bool) -> Void
}

// willAppearholder
public extension ControllerWithFirstAppearHelper {
    private static var willAppearImp: ClosureType = { vc, sel, animated in
        if let vc = vc as? ControllerWithFirstAppear {
            vc.beforeViewWillAppear(first: vc.firstAppear.will)
        }

        if let c = willAppearholder.storedFunc {
            c(vc, sel, animated)
        }

        if let vc = vc as? ControllerWithFirstAppear {
            vc.afterViewWillAppear(first: vc.firstAppear.will)
            vc.firstAppear.will = false
        }
    }

    private static var willAppearholder = YXHookHolder(replace: willAppearImp)

    static func hookWillAppear() {
        UIViewController.yxSwizzle(original: #selector(UIViewController.viewWillAppear(_:)),
                                   holder: willAppearholder)
    }
}

extension ControllerWithFirstAppearHelper {
    private static var didAppearImp: ClosureType = { vc, sel, animated in
        if let vc = vc as? ControllerWithFirstAppear {
            vc.beforeViewDidAppear(first: vc.firstAppear.did)
        }

        if let c = didAppearholder.storedFunc {
            c(vc, sel, animated)
        }

        if let vc = vc as? ControllerWithFirstAppear {
            vc.afterViewDidAppear(first: vc.firstAppear.did)
            vc.firstAppear.did = false
        }
    }

    private static var didAppearholder = YXHookHolder(replace: didAppearImp)

    static func hookDidAppear() {
        UIViewController.yxSwizzle(original: #selector(UIViewController.viewDidAppear(_:)),
                                   holder: didAppearholder)
    }
}

public extension ControllerWithFirstAppearHelper {
    static func hookAll() {
        hookWillAppear()
        hookDidAppear()
    }
}
