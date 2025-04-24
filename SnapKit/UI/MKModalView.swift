//
//  MKModalView.swift
//
//  Created by MK on 2021/6/19.
//

import UIKit

// MARK: - MKModalView

open class MKModalView: TouchPassthroughView {
    public enum Style {
        case bottom
        case top
        case center
    }

    private(set) var contentView: UIView?

    public lazy var hideAlpha: CGFloat = 0.0

    public let style: Style
    public var willHideCallback: ((MKModalView?, Any?) -> Void)?
    public var didHideCallback: ((MKModalView?, Any?) -> Void)?

    public var willShowCallback: ((MKModalView?) -> Void)?
    public var didShowCallback: ((MKModalView?) -> Void)?

    public private(set) lazy var bgTouchView: TouchPassthroughView = {
        let view = TouchPassthroughView()
        view.frame = self.bounds
        view.passMode = .none
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .black.withAlphaComponent(0.3)
        return view
    }()

    public init(frame: CGRect, style: Style) {
        self.style = style
        super.init(frame: frame)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        bgTouchView.addGestureRecognizer(gesture)
        passMode = .none

        addSubview(bgTouchView)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setContentView(_ view: UIView) {
        contentView = view
        addSubview(view)
    }

    public var dismissOnBackgroundTap: Bool = true
}

public extension MKModalView {
    var touchViewPassMode: PassMode {
        get {
            bgTouchView.passMode
        }
        set {
            bgTouchView.passMode = newValue
        }
    }

    var touchViewColor: UIColor? {
        get {
            bgTouchView.backgroundColor
        }
        set {
            bgTouchView.backgroundColor = newValue
        }
    }
}

public extension MKModalView {
    private var showDuration: CFTimeInterval { style == .center ? 0.2 : 0.3 }
    private var hideDuration: CFTimeInterval { style == .center ? 0.2 : 0.3 }

    func show(animated: Bool = true, _ container: UIView? = nil) {
        guard contentView != nil, let superView = container ?? ScreenUtil.window else {
            return
        }

        weak var weakSelf = self

        if let callback = willShowCallback {
            callback(weakSelf)
        }

        frame = superView.bounds
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        superView.addSubview(self)

        layoutIfNeeded()

        let showBlock: VoidFunction = { [weak self] in
            self?.realShow()
        }
        let afterShowBlock: VoidFunction = { [weak self] in
            self?.afterShow()
        }
        let actionBlock: VoidFunction = { [weak self] in
            guard let self else {
                return
            }
            beforeShow()
            if animated {
                UIView.animate(withDuration: showDuration,
                               animations: showBlock)
                { _ in
                    afterShowBlock()
                }
            } else {
                showBlock()
                afterShowBlock()
            }
        }

        if style == .center {
            DispatchQueue.mainAsync {
                actionBlock()
            }
        } else {
            actionBlock()
        }
    }

    @objc private func dismiss() {
        if dismissOnBackgroundTap {
            hide()
        }
    }

    func hide(animated: Bool = true, by object: AnyObject? = nil) {
        willHideCallback?(self, object)

        let hideBlock: VoidFunction = { [weak self] in
            self?.realHide()
        }
        let afterHideBlock: VoidFunction = { [weak self] in
            self?.removeFromSuperview()
            self?.contentView?.removeFromSuperview()
            self?.didHideCallback?(self, object)
        }

        if animated {
            UIView.animate(withDuration: hideDuration,
                           animations: hideBlock)
            { _ in
                afterHideBlock()
            }
        } else {
            hideBlock()
            afterHideBlock()
        }
    }
}

private extension MKModalView {
    func beforeShow() {
        guard let contentView else {
            return
        }

        bgTouchView.alpha = hideAlpha
        bgTouchView.isUserInteractionEnabled = false

        if style == .center {
            let scale: CGFloat = 1.12
            contentView.transform = CGAffineTransform(scaleX: scale, y: scale)
        } else {
            var rect = contentView.frame
            if style == .top {
                rect.origin.y = -rect.height
            } else if style == .bottom {
                rect.origin.y = bounds.size.height
            }
            contentView.frame = rect
        }
    }

    func realShow() {
        guard let contentView else {
            return
        }

        bgTouchView.alpha = 1

        if style == .center {
            contentView.transform = .identity
            layoutIfNeeded()
        } else {
            var rect = contentView.frame
            if style == .top {
                rect.origin.y = 0
            } else if style == .bottom {
                rect.origin.y = bounds.size.height - rect.height
            }
            contentView.frame = rect
        }
    }

    func afterShow() {
        didShowCallback?(self)
        bgTouchView.isUserInteractionEnabled = true
    }

    func realHide() {
        if style == .center {
            alpha = hideAlpha
            if let contentView {
                let scale: CGFloat = 0.8
                contentView.transform = .identity.scaledBy(x: scale, y: scale)
                layoutIfNeeded()
            }
        } else {
            beforeShow()
        }
    }
}

public extension MKModalView {
    @discardableResult
    static func showFromBottom<T: UIView>(_ contentView: T,
                                          in container: UIView? = nil,
                                          configure: (MKModalView, T) -> Void) -> MKModalView
    {
        show(contentView, style: .bottom, in: container, configure: configure)
    }

    @discardableResult
    static func show<T: UIView>(_ contentView: T,
                                animated: Bool = true,
                                style: MKModalView.Style,
                                in container: UIView? = nil,
                                configure: (MKModalView, T) -> Void) -> MKModalView
    {
        let modalView = MKModalView(frame: .zero, style: style)
        modalView.setContentView(contentView)

        configure(modalView, contentView)

        contentView.frame = modalView.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        modalView.show(animated: animated, container)
        return modalView
    }
}

public extension MKModalView {
    @discardableResult
    static func showBottomSheet<T: UIView>(_ contentView: T,
                                           touchToDismiss: Bool = true,
                                           in container: UIView?,
                                           configure: ((MKModalView, T) -> Void)? = nil) -> MKModalView?
    {
        guard let superView = container ?? ScreenUtil.window else {
            return nil
        }
        let box = TouchPassthroughView(frame: superView.bounds)
        box.addSnpSubview(contentView)

        return MKModalView.showFromBottom(box, in: container) { modalView, _ in
            if !touchToDismiss {
                modalView.dismissOnBackgroundTap = false
            }

            configure?(modalView, contentView)
        }
    }

    @discardableResult
    static func showTop<T: UIView>(_ contentView: T,
                                   touchToDismiss: Bool = true,
                                   in container: UIView?,
                                   configure: ((MKModalView, T) -> Void)? = nil) -> MKModalView?
    {
        guard let superView = container ?? ScreenUtil.window else {
            return nil
        }

        let box = TouchPassthroughView(frame: superView.bounds)
        box.addSnpSubview(contentView)

        return MKModalView.show(box, style: .top, in: container) { modalView, _ in
            if !touchToDismiss {
                modalView.dismissOnBackgroundTap = false
            }
            configure?(modalView, contentView)
        }
    }

    @discardableResult
    static func showCenter<T: UIView>(_ contentView: T,
                                      touchToDismiss: Bool = true,
                                      in container: UIView?,
                                      configure: (MKModalView, T) -> Void) -> MKModalView?
    {
        guard let superView = container ?? ScreenUtil.window else {
            return nil
        }

        let box = TouchPassthroughView(frame: superView.bounds)

        contentView.addSnpConfig { _, make in
            make.center.equalToSuperview()
        }
        box.addSnpSubview(contentView)

        return MKModalView.show(box, style: .center) { modalView, _ in
            if !touchToDismiss {
                modalView.dismissOnBackgroundTap = false
            }

            configure(modalView, contentView)
        }
    }
}
