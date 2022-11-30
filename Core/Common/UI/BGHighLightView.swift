//
//  BGHighLightView.swift
//
//
//  Created by MK on 2022/3/29.
//

import Async
import UIKit

// MARK: - BaseHighLightView

open class BaseHighLightView: UIView {
    private var blockObx: AsyncBlock<Void, Any>?
    private var highLightedDate: Date?
    
    open var isHighLighted: Bool = false {
        didSet {
            blockObx?.cancel()

            if isHighLighted {
                highLightedDate = Date()
                updateHighlightStateUI(highLighted: true)
            } else {
                let cb: VoidFunction = { [weak self] in
                    self?.updateHighlightStateUI(highLighted: false)
                }
                if let date = highLightedDate {
                    let interval = minHighLightDruation + date.timeIntervalSinceNow
                    if interval > 0 {
                        blockObx = Async.main(after: interval, cb)
                    } else {
                        cb()
                    }
                } else {
                    cb()
                }
            }
        }
    }

    open func updateHighlightStateUI(highLighted _: Bool) {}

    open var minHighLightDruation: TimeInterval = 0.1

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

open class BGHighLightView: BaseHighLightView {
    open var bgHighLightColor: UIColor?
    open var bgColor: UIColor?

    override open func updateHighlightStateUI(highLighted: Bool) {
        backgroundColor = highLighted ? bgHighLightColor : bgColor
        subviews.forEach {
            Self.updateState(view: $0, isHighLighted: highLighted)
        }
    }

    override open var backgroundColor: UIColor? {
        didSet {
            if !isHighLighted {
                bgColor = backgroundColor
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

open class OverlayHighlightView: BaseHighLightView {
    open var overlayColor: UIColor?
    private var overlay: UIView?

    override open func updateHighlightStateUI(highLighted: Bool) {
        overlay?.removeFromSuperview()
        overlay = nil

        if highLighted {
            let overlay = UIView(frame: bounds)
            overlay.backgroundColor = overlayColor
            addSubview(overlay)

            self.overlay = overlay
        }
    }
}

// MARK: - ScaleHighlightView

class ScaleHighlightView: BaseHighLightView {
    var animateDuration: Double = 0.3
    var target: CGFloat = 0.9

    override open func updateHighlightStateUI(highLighted: Bool) {
        let from = highLighted ? 1.0 : target
        let to = highLighted ? target : 1.0
        transform = CGAffineTransform(scaleX: from, y: from)
        UIView.animate(withDuration: animateDuration, delay: 0.0, options: .curveLinear, animations: {
            self.transform = CGAffineTransform(scaleX: to, y: to)
        }, completion: nil)
    }
}
