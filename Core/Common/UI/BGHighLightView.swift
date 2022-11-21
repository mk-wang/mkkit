//
//  BGHighLightView.swift
//
//
//  Created by MK on 2022/3/29.
//

import UIKit

// MARK: - BaseHighLightView

open class BaseHighLightView: UIView {
    open var isHighLighted: Bool = false

    open var highLightOnTouch: Bool = true
    open var disableHighLightOnEnd: Bool = true

    fileprivate var keepHighLight = false

    open func highLight(for duartion: Double = 0.3) {
        isHighLighted = true
        keepHighLight = true

        DispatchQueue.mainAsync(after: duartion) {
            [weak self] in
            self?.keepHighLight = false
            self?.isHighLighted = false
        }
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if highLightOnTouch {
            isHighLighted = true
        }

        super.touchesBegan(touches, with: event)
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if highLightOnTouch {
            isHighLighted = true
        }
        super.touchesMoved(touches, with: event)
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if disableHighLightOnEnd, !keepHighLight {
            isHighLighted = false
        }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if disableHighLightOnEnd, !keepHighLight {
            isHighLighted = false
        }
    }
}

// MARK: - BGHighLightView

class BGHighLightView: BaseHighLightView {
    var bgHighLightColor: UIColor?

    override var isHighLighted: Bool {
        didSet {
            backgroundColor = isHighLighted ? bgHighLightColor : .clear
            subviews.forEach {
                Self.updateState(view: $0, isHighLighted: isHighLighted)
            }
        }
    }

    private static func updateState(view: UIView, isHighLighted: Bool) {
        if let view = view as? UILabel {
            view.isHighlighted = isHighLighted
            return
        } else if let view = view as? UIImageView {
            view.isHighlighted = isHighLighted
            return
        } else if let control = view as? UIControl {
            control.isHighlighted = isHighLighted
        }
        view.subviews.forEach {
            Self.updateState(view: $0, isHighLighted: isHighLighted)
        }
    }
}

// MARK: - OverlayHighlightView

class OverlayHighlightView: BaseHighLightView {
    var overlayColor: UIColor?
    private var overlay: UIView?

    override var isHighLighted: Bool {
        didSet {
            overlay?.removeFromSuperview()
            overlay = nil

            if isHighLighted {
                let overlay = UIView(frame: bounds)
                overlay.backgroundColor = overlayColor
                addSubview(overlay)

                self.overlay = overlay
            }
        }
    }
}

// MARK: - ScaleHighlightView

class ScaleHighlightView: BaseHighLightView {
    var animateDuration: Double = 0.3
    var target: CGFloat = 0.9

    override var isHighLighted: Bool {
        didSet {
            let from = isHighLighted ? 1.0 : target
            let to = isHighLighted ? target : 1.0
            transform = CGAffineTransform(scaleX: from, y: from)
            UIView.animate(withDuration: animateDuration, delay: 0.0, options: .curveLinear, animations: {
                self.transform = CGAffineTransform(scaleX: to, y: to)
            }, completion: nil)
        }
    }
}
