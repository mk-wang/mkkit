//
//  ActivityIndicatorView.swift
//  MKKit
//
//  Created by MK on 2023/2/17.
//

import UIKit

open class ActivityIndicatorView: UIView {
    public let indicator: UIActivityIndicatorView

    public init(style: UIActivityIndicatorView.Style) {
        indicator = UIActivityIndicatorView(style: style)
        super.init(frame: .zero)
        addSubview(indicator)
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
        indicator.intrinsicContentSize
    }

    private func updateUI() {
        let size = bounds.size
        guard size.width > 0, size.height > 0 else {
            return
        }
        indicator.center = CGPoint(size.width / 2, size.height / 2)
        let indicatorSize = indicator.bounds.size
        let scale: CGFloat = size.height / indicatorSize.height
        indicator.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
}
