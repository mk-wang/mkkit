//
//  MKBaseViewController.swift
//  MKKit
//
//  Created by MK on 2024/5/10.
//

import Foundation
#if canImport(OpenCombine)
    import OpenCombine
#elseif canImport(Combine)
    import Combine
#endif

// MARK: - MKBaseViewController

open class MKBaseViewController: UIViewController {
    public let titleSubject = CurrentValueSubject<String?, Never>("")

    #if DEBUG_BUILD
        open var debug: Bool = false
    #endif

    private let willAppearCountSubject: CurrentValueSubject<Int, Never> = .init(0)
    public lazy var willAppearCountPublisher = willAppearCountSubject.dropFirst().eraseToAnyPublisher()
    public private(set) var willAppearCount: Int {
        get {
            willAppearCountSubject.value
        }
        set {
            willAppearCountSubject.value = newValue
        }
    }

    private let didAppearCountSubject: CurrentValueSubject<Int, Never> = .init(0)
    public lazy var didAppearCountPublisher = didAppearCountSubject.dropFirst().eraseToAnyPublisher()
    public private(set) var didAppearCount: Int {
        get {
            didAppearCountSubject.value
        }
        set {
            didAppearCountSubject.value = newValue
        }
    }

    public var onDeinit: VoidFunction?

    public var statusBarLight: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }

    override public var title: String? {
        didSet {
            titleSubject.value = title
        }
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        doInit()
    }

    override public required init?(coder: NSCoder) {
        super.init(coder: coder)
        doInit()
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        #if DEBUG && targetEnvironment(simulator)
            setupInjections()
        #endif
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if view.isReadyToConfig {
            readyToLayout()
        }
    }

    override open func viewWillAppear(_ animated: Bool) {
        willAppearCount += 1
        super.viewWillAppear(animated)

        if willAppearCount == 1 {
            onFirstWillAppear()
        }
    }

    override open func viewDidAppear(_ animated: Bool) {
        didAppearCount += 1
        super.viewDidAppear(animated)

        if didAppearCount == 1 {
            onFirstDidAppear()
        }
    }

    override open var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarLight ? .lightContent : .darkOrDefault
    }

    override open func push(vc: UIViewController, animated: Bool = true) {
        #if DEBUG_BUILD
            if let base = vc as? MKBaseViewController {
                base.debug = debug
            }
        #endif
        super.push(vc: vc, animated: animated)
    }

    override open func present(_ vc: UIViewController,
                               animated flag: Bool,
                               completion: (() -> Void)? = nil)
    {
        #if DEBUG_BUILD
            if let base = vc as? MKBaseViewController {
                base.debug = debug
            }
        #endif
        super.present(vc, animated: flag, completion: completion)
    }

    deinit {
        onDeinit?()
    }
}

// MARK:

extension MKBaseViewController {
    @objc open func doInit() {}

    @objc open func refresh() {}

    @objc open func readyToLayout() {}

    @objc open func onFirstWillAppear() {}

    @objc open func onFirstDidAppear() {}
}

// MARK: InjectionIII

extension MKBaseViewController: InjectionIII {
    @objc func setupInjections() {
        addInjection { [weak self] in
            self?.refresh()
        }
    }
}
