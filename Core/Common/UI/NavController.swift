//
//  NavController.swift
//
//  Created by MK on 2024/7/17.
//

import UIKit

// MARK: - MKNavController

open class MKNavController: UINavigationController {
    private struct PopInfo {
        let list: [UIViewController]
    }

    private var popListSubject: PassthroughSubjectType<[UIViewController], Never> = .init()
    public private(set) lazy var popListPublisher = popListSubject.eraseToAnyPublisher()

    private var pop: PopInfo? = nil
    private var currentList: [UIViewController] = []

    deinit {
        delegate = nil
        interactivePopGestureRecognizer?.removeTarget(self, action: #selector(handlePopGesture(_:)))
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        delegate = self
        interactivePopGestureRecognizer?.addTarget(self, action: #selector(handlePopGesture(_:)))

        Lang.rltPublisher
            .sink { [weak self] in
                self?.applayLangConfig(rtl: $0)
            }.store(in: self)
    }

    override open var childForStatusBarStyle: UIViewController? {
        visibleViewController
    }
}

extension MKNavController {
    @objc
    private func handlePopGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        switch gesture.state {
        case .began:
            pop = PopInfo(list: currentList)
        case .changed:
            break
        case .ended:
            break
        case .cancelled,
             .failed:
            pop = nil
        default:
            break
        }
    }
}

// MARK: UINavigationControllerDelegate

extension MKNavController: UINavigationControllerDelegate {
    open func navigationController(_: UINavigationController,
                                   didShow vc: UIViewController,
                                   animated _: Bool)
    {
        var target = vc.disableSlidePanGusture
        if target {
            #if DEBUG_BUILD
                if let isDebug = (vc as? MKBaseViewController)?.debug, isDebug {
                    target = false
                }
            #endif
        }

        interactivePopGestureRecognizer?.isEnabled = !target
        currentList = viewControllers

        guard let pop else {
            return
        }

        let removed = pop.list.filter { !currentList.contains($0) }
        if removed.isNotEmpty {
            popListSubject.send(removed)
        }
        self.pop = nil
    }
}

public extension UIViewController {
    var disableSlidePanGusture: Bool {
        get {
            (getAssociatedObject(&AssociatedKeys.kDisableSlidePanGusture) as? NSNumber)?.boolValue ?? false
        }

        set {
            setAssociatedObject(&AssociatedKeys.kDisableSlidePanGusture, NSNumber(value: newValue))
        }
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kDisableSlidePanGusture = 0
}

// MARK: - MainTabBarDelegate
