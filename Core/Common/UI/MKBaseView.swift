//
//  MKBaseView.swift
//  MKKit
//
//  Created by MK on 2023/10/31.
//

import Foundation

// MARK: - MKBaseView

open class MKBaseView: UIView {
    open var readyToLayoutBlock: VoidFunction?
    open var isReady: Bool = false

    open var extendHitInset: UIEdgeInsets?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        doInit()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if tag == 999 {}

        if isReadyToConfig {
            isReady = true
            readyToLayout()
            readyToLayoutBlock?()
        }
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var inside = super.point(inside: point, with: event)
        guard !inside, let extendHitInset else {
            return inside
        }
        let rect = bounds.inset(by: extendHitInset)
        inside = rect.contains(point)

        return inside
    }
}

extension MKBaseView {
    @objc open func doInit() {}

    @objc open func readyToLayout() {}
}
