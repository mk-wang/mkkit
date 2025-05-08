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

    open private(set) var isTouching: Bool = false

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

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = true
        super.touchesBegan(touches, with: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isTouching = false
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        isTouching = false
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()
        if isTouching, window == nil {
            touchesCancelled([], with: nil)
        }
    }
}

extension MKBaseView {
    @objc open func doInit() {}

    @objc open func readyToLayout() {}
}
