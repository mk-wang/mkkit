//
//  BGHighLightView.swift
//
//
//  Created by MK on 2022/3/29.
//

import UIKit

// MARK: - BaseHighLightView

open class BaseHighLightView: UIView {
    private var highLightTimer: SwiftTimer?
    private var highLightedDate: Date?
    private var unhighLightTimer: SwiftTimer?

    open var isHighLighted: Bool = false {
        didSet {
            unhighLightTimer = nil
            highLightTimer = nil

            if isHighLighted {
                highLightedDate = Date()

                highLightTimer = SwiftTimer(interval: .fromSeconds(highLightDelay),
                                            handler: { [weak self] _ in
                                                self?.updateHighlightStateUI(highLighted: true)
                                            })
                highLightTimer?.start()
            } else {
                let cb: VoidFunction = { [weak self] in
                    self?.updateHighlightStateUI(highLighted: false)
                }
                if let date = highLightedDate {
                    let interval = minHighLightDruation + date.timeIntervalSinceNow
                    if interval > 0 {
                        unhighLightTimer = SwiftTimer(interval: .fromSeconds(interval),
                                                      handler: { _ in
                                                          cb()
                                                      })
                        unhighLightTimer?.start()
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
    open var highLightDelay: TimeInterval = 0

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

    public func reset() {
        isHighLighted = false
        keepHighLight = false
        highLightTimer = nil
        unhighLightTimer = nil
        updateHighlightStateUI(highLighted: false)
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

        if event?.type == .touches,
           let touch = touches.first,
           bounds.contains(touch.location(in: self))
        {
            onTouchSideUp()
        }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        if disableHighLightOnEnd, !keepHighLight {
            isHighLighted = false
        }
    }
}

extension BaseHighLightView {
    @objc open func onTouchSideUp() {}
}

// MARK: - BGHighLightView

open class BGHighLightView: BaseHighLightView {
    open var bgHighLightColor: UIColor?
    open var bgColor: UIColor?

    override open func updateHighlightStateUI(highLighted: Bool) {
        let target = highLighted ? bgHighLightColor : bgColor
        weak var weakSelf = self
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                weakSelf?.backgroundColor = target
            }, completion: nil
        )
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
    open var overlayColor: UIColor? {
        didSet {
            cleanHighlightHandler()

            if let overlayColor {
                addHighlightHandler(OverlayViewHighlightHandler(overlayColor))
            }
        }
    }

    override open func updateHighlightStateUI(highLighted: Bool) {
        handleHighlightState(highLighted: highLighted)
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
