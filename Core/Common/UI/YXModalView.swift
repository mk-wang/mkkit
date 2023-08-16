//
//  YXModalView.swift
//
//  Created by MK on 2021/6/19.
//

import UIKit

// MARK: - YXModalView

open class YXModalView: YXPassTouchView {
    public enum Style {
        case bottom
        case top
        case center
    }

    private(set) var contentView: UIView?
    lazy var duration: CFTimeInterval = style == .center ? 0.2 : 0.3
    lazy var hideAlpha: CGFloat = 0.0

    public let style: Style
    public var willHideCallback: ((YXModalView?, Any?) -> Void)?
    public var didHideCallback: ((YXModalView?, Any?) -> Void)?

    public var willShowCallback: ((YXModalView?) -> Void)?
    public var didShowCompletion: ((YXModalView?) -> Void)?

    public private(set) lazy var bgTouchView: YXPassTouchView = {
        let view = YXPassTouchView()
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
}

public extension YXModalView {
    var touchBGColor: UIColor? {
        get {
            bgTouchView.backgroundColor
        }
        set {
            bgTouchView.backgroundColor = newValue
        }
    }

    func show(_ container: UIView? = nil) {
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

        if style == .center {
            let duration = duration
            DispatchQueue.mainAsync {
                weakSelf?.beforeShow()

                UIView.animate(withDuration: duration) {
                    weakSelf?.realShow()
                } completion: { _ in
                    weakSelf?.didShowCompletion?(weakSelf)
                }
            }
        } else {
            beforeShow()

            UIView.animate(withDuration: duration) {
                weakSelf?.realShow()
            } completion: { _ in
                weakSelf?.didShowCompletion?(weakSelf)
            }
        }
    }

    @objc private func dismiss() {
        hide()
    }

    func hide(by object: AnyObject? = nil, duration: TimeInterval? = nil) {
        willHideCallback?(self, object)

        weak var weakSelf = self

        UIView.animate(withDuration: duration ?? self.duration) {
            weakSelf?.realHide()
        } completion: { [weak object] _ in
            weakSelf?.removeFromSuperview()
            weakSelf?.contentView?.removeFromSuperview()
            weakSelf?.didHideCallback?(weakSelf, object)
        }
    }
}

private extension YXModalView {
    func beforeShow() {
        guard let contentView else {
            return
        }

        bgTouchView.alpha = hideAlpha

        if style == .center {
            let scale: CGFloat = 1.12
            contentView.transform = .identity.scaledBy(x: scale, y: scale)
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

public extension YXModalView {
    @discardableResult
    static func showFromBottom<T: UIView>(_ contentView: T,
                                          in container: UIView? = nil,
                                          configure: (YXModalView, T) -> Void) -> YXModalView
    {
        show(contentView, style: .bottom, in: container, configure: configure)
    }

    @discardableResult
    static func show<T: UIView>(_ contentView: T,
                                style: YXModalView.Style,
                                in container: UIView? = nil,
                                configure: (YXModalView, T) -> Void) -> YXModalView
    {
        let modalView = YXModalView(frame: .zero, style: style)
        modalView.setContentView(contentView)

        configure(modalView, contentView)

        contentView.frame = modalView.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        modalView.show(container)
        return modalView
    }
}
