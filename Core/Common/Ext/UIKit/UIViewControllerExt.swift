//
//  UIViewControllerExt.swift
//
//
//  Created by MK on 2021/6/10.
//

import UIKit

public extension UIViewController {
    var isUILoaded: Bool {
        isViewLoaded && view.window != nil
    }

    var safeAreaRect: CGRect {
        view.bounds.inset(by: view.safeAreaInsets)
    }
}

public extension UIViewController {
    @objc open func disableSlidePan() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    @objc open func enableSlidePan() {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

public extension UIViewController {
    @objc open func push(vc: UIViewController, animated: Bool = true) {
        navigationController?.pushViewController(vc, animated: animated)
    }

    @objc open func goBack(animated: Bool, completion: (() -> Void)? = nil) {
        if let nav = navigationController {
            if nav.children.count < 2 {
                nav.dismiss(animated: animated, completion: completion)
            } else {
                nav.popViewController(animated: animated)
                if let cb = completion {
                    DispatchQueue.main.async {
                        cb()
                    }
                }
            }
        } else {
            dismiss(animated: animated, completion: completion)
        }
    }
}

// MARK: - YXViewControllerTop

public protocol YXViewControllerTop: UIViewController {
    func getTopController() -> UIViewController?
}

public extension UIViewController {
    var topController: UIViewController? {
        var top: UIViewController?
        traveToTop { vc, _ in
            top = vc
        }
        return top
    }

    func traveToTop(visitor: @escaping (UIViewController, inout Bool) -> Void) {
        var stop = false

        var top: UIViewController? = self
        while top != nil {
            var next: UIViewController?

            if let vc = top?.presentedViewController {
                next = vc
            } else if let nav = top as? UINavigationController {
                next = nav.topViewController
            } else if let tab = top as? UITabBarController {
                next = tab.selectedViewController
            } else if let vc = top as? YXViewControllerTop {
                next = vc.getTopController()
            }

            if let vc = next {
                visitor(vc, &stop)
                top = next

                if stop {
                    break
                }
            } else {
                break
            }
        }
    }
}
