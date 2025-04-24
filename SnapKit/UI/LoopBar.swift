//
//  LoopBar.swift
//
//  Created by MK on 2025/3/21.
//

import UIKit

public class LoopBar: MKAnimationView {
    public struct Config {
        public let duration: TimeInterval
        public let barBuilder: ValueBuilder1<UIView, LoopBar>

        public init(duration: TimeInterval, barBuilder: @escaping ValueBuilder1<UIView, LoopBar>) {
            self.duration = duration
            self.barBuilder = barBuilder
        }
    }

    private lazy var loopView1: UIView = config.barBuilder(self)
    private lazy var loopView2: UIView = config.barBuilder(self)

    let config: Config

    public init(frame: CGRect,
                config: Config)
    {
        self.config = config
        super.init(frame: frame)
    }

    override public func readyToLayout() {
        super.readyToLayout()

        addSnpSubview(loopView1)
        addSnpSubview(loopView2)

        resetPosition(loopView1)
        resetPosition(loopView2)
    }

    override open func doAnimation() {
        resetPosition(loopView1)
        animateView(loopView1)

        resetPosition(loopView2)
        animateView(loopView2)
    }

    override open func cancelAnimation() {
        loopView1.layer.removeAllAnimations()
        loopView2.layer.removeAllAnimations()

        resetPosition(loopView1)
        resetPosition(loopView2)
    }

    override open func readyToAnimtaion() -> Bool {
        loopView1.superview != nil
    }

    private func animateView(_ view: UIView) {
        let viewWidth = frame.width
        let duration = config.duration

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: .curveLinear)
        {
            if Lang.current.isRTL {
                view.frame.origin.x -= viewWidth
            } else {
                view.frame.origin.x += viewWidth
            }
        } completion: { [weak self] finished in
            if finished, view == self?.loopView1 {
                self?.doAnimation()
            }
        }
    }

    private func resetPosition(_ view: UIView?) {
        let viewWidth = frame.width

        if view == loopView1 {
            loopView1.frame.origin.x = 0
        } else if view == loopView2 {
            if Lang.current.isRTL {
                loopView2.frame.origin.x = viewWidth
            } else {
                loopView2.frame.origin.x = -viewWidth
            }
        }
    }
}
