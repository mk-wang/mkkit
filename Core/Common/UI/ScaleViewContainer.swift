//
//  ScaleViewContainer.swift
//  MKKit
//
//  Created by MK on 2023/8/29.
//

import UIKit

// MARK: - ScaleViewContainer

open class ScaleViewContainer<T: UIView>: UIView {
    public let inner: T

    init(frame: CGRect, builder: () -> T) {
        inner = builder()
        super.init(frame: frame)

        addSubview(inner)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }

    override open var frame: CGRect {
        get {
            super.frame
        }
        set {
            super.frame = newValue
            updateUI()
        }
    }

    override open var intrinsicContentSize: CGSize {
        inner.intrinsicContentSize
    }

    private func updateUI() {
        let size = bounds.size
        guard size.width > 0, size.height > 0 else {
            return
        }
        inner.center = CGPoint(size.width / 2, size.height / 2)
        let indicatorSize = inner.bounds.size
        let scale: CGFloat = min(size.width / indicatorSize.width, size.height / indicatorSize.height)
        inner.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}

// MARK: - MKActivityIndicatorView

open class MKActivityIndicatorView: ScaleViewContainer<UIActivityIndicatorView> {
    public init(frame: CGRect, style: UIActivityIndicatorView.Style) {
        super.init(frame: frame) {
            UIActivityIndicatorView(style: style)
        }
    }

    public var hidesWhenStopped: Bool {
        get {
            inner.hidesWhenStopped
        }

        set {
            inner.hidesWhenStopped = newValue
        }
    }

    public var color: UIColor? {
        get {
            inner.color
        }

        set {
            inner.color = newValue
        }
    }

    public func startAnimating() {
        inner.startAnimating()
    }

    public func stopAnimating() {
        inner.stopAnimating()
    }
}

// MARK: - MKSwitch

open class MKSwitch: ScaleViewContainer<UISwitch> {
    public init(frame: CGRect) {
        super.init(frame: frame) {
            UISwitch()
        }
    }

    public var isOn: Bool {
        get {
            inner.isOn
        }
        set {
            inner.isOn = newValue
        }
    }
}
