//
//  YXModalView.swift
//  YogaWorkout
//
//  Created by MK on 2021/6/19.
//

import MKKit
import UIKit

// MARK: - YXModalView

open class YXModalView: UIView {
    public enum Style {
        case bottom
        case top
    }

    private(set) var contentView: UIView?
    var duration: CFTimeInterval = 0.3
    var hideAlpha: CGFloat = 0.0

    public let style: Style
    public var willHideCallback: YXModalViewCallback?
    public var didHideCallback: YXModalViewCallback?

    public var willShowCallback: YXModalViewCallback?
    public var didShowCompletion: YXModalViewCallback?

    public private(set) lazy var bgTouchView: UIView = {
        let view = UIView()
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .black.withAlphaComponent(0.3)
        return view
    }()

    public init(frame: CGRect, style: Style) {
        self.style = style
        super.init(frame: frame)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        bgTouchView.addGestureRecognizer(gesture)

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
    typealias YXModalViewCallback = (YXModalView?) -> Void

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
        beforeShow()

        UIView.animate(withDuration: duration) {
            weakSelf?.realShow()
        } completion: { _ in
            weakSelf?.didShowCompletion?(weakSelf)
        }
    }

    @objc func hide() {
        weak var weakSelf = self

        if let callback = willHideCallback {
            callback(weakSelf)
        }

        UIView.animate(withDuration: duration) {
            weakSelf?.beforeShow()
        } completion: { _ in
            weakSelf?.removeFromSuperview()
            weakSelf?.contentView?.removeFromSuperview()
            weakSelf?.didHideCallback?(weakSelf)
        }
    }
}

private extension YXModalView {
    func beforeShow() {
        guard let contentView else {
            return
        }

        bgTouchView.alpha = hideAlpha

        var rect = contentView.frame
        if style == .bottom {
            rect.origin.y = bounds.size.height
        } else if style == .top {
            rect.origin.y = -rect.height
        }
        contentView.frame = rect
    }

    func realShow() {
        guard let contentView else {
            return
        }

        bgTouchView.alpha = 1

        var rect = contentView.frame
        if style == .bottom {
            rect.origin.y = bounds.size.height - rect.height
        } else if style == .top {
            rect.origin.y = 0
        }
        contentView.frame = rect
    }
}

public extension YXModalView {
    @discardableResult
    static func showFromBottom<T: UIView>(_ contentView: T,
                                          in container: UIView? = nil,
                                          configre: (YXModalView, T) -> Void) -> YXModalView
    {
        let modalView = YXModalView(frame: .zero, style: .bottom)
        modalView.setContentView(contentView)

        configre(modalView, contentView)

        contentView.frame = modalView.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        modalView.show(container)
        return modalView
    }

    @discardableResult
    static func showFromTop<T: UIView>(_ contentView: T,
                                       in container: UIView? = nil,
                                       configre: (YXModalView, T) -> Void) -> YXModalView
    {
        let modalView = YXModalView(frame: .zero, style: .top)
        modalView.setContentView(contentView)

        configre(modalView, contentView)

        contentView.frame = modalView.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        modalView.show(container)
        return modalView
    }
}
