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
    enum Style {
        case bottom
    }

    private(set) var contentView: UIView?
    var duration: CFTimeInterval = 0.3
    var hideAlpha: CGFloat = 0.0

    var style: Style = .bottom
    var willHideCallback: YXModalViewCallback?
    var didHideCallback: YXModalViewCallback?

    var willShowCallback: YXModalViewCallback?
    var didShowCompletion: YXModalViewCallback?

    private lazy var touchView: UIView = {
        let view = UIView()
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.backgroundColor = .black.withAlphaComponent(0.3)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let gesture = UITapGestureRecognizer(target: self, action: #selector(hide))
        touchView.addGestureRecognizer(gesture)

        addSubview(touchView)
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
    internal typealias YXModalViewCallback = (YXModalView?) -> Void

    func show(_ container: UIView? = nil) {
        guard contentView != nil, let superView = container ?? ScreenUtil.window else {
            return
        }

        weak var weakSelf = self

        if let callback = willShowCallback {
            callback(weakSelf)
        }

        frame = superView.bounds
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
            weakSelf?.realHide()
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
        let selfSize = bounds.size

        if style == .bottom {
            var rect = contentView.frame
            rect.origin.y = selfSize.height
            contentView.frame = rect
            touchView.alpha = hideAlpha
        }
    }

    func realShow() {
        guard let contentView else {
            return
        }
        let selfSize = bounds.size

        if style == .bottom {
            touchView.alpha = 1
            var rect = contentView.frame
            rect.origin.y = selfSize.height - rect.height
            contentView.frame = rect
        }
    }

    func realHide() {
        guard let contentView else {
            return
        }

        if style == .bottom {
            touchView.alpha = hideAlpha
            var rect = contentView.frame
            rect.origin.y = bounds.height
            contentView.frame = rect
        }
    }
}

public extension YXModalView {
    @discardableResult
    static func showFromBottom<T: UIView>(_ contentView: T,
                                          in container: UIView? = nil,
                                          configre: (YXModalView, T) -> Void) -> YXModalView
    {
        let modalView = YXModalView()
        modalView.setContentView(contentView)
        modalView.addSubview(contentView)

        configre(modalView, contentView)

        contentView.frame = modalView.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        modalView.show(container)
        return modalView
    }
}
