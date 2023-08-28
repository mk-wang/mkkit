//
//  PassTouchView.swift
//  MKKit
//
//  Created by MK on 2023/8/8.
//

import UIKit

open class PassTouchView: UIView {
    public enum PassMode {
        case none
        case contain
        case all
    }

    open var passMode: PassMode = .contain

    open var pointTestCallback: ((CGPoint) -> Bool?)?

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let pointTestCallback, let value = pointTestCallback(point) {
            return value
        }

        switch passMode {
        case .none:
            return super.point(inside: point, with: event)
        case .contain:
            for subView in subviews {
                if subView.frame.contains(point) {
                    return true
                }
            }
            return false
        case .all:
            return false
        }
    }
}
