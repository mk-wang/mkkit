//
//  MKAnimationView.swift
//  Pods
//
//  Created by MK on 2025/3/21.
//

import UIKit

// MARK: - MKAnimationView

open class MKAnimationView: MKBaseView {
    private var obs: AnyCancellableType?

    // nil: 表示不需要动画
    // false: 表示需要动画，但是时机不对
    // true: 表示再做动画
    private var started: Bool?
    public var running: Bool {
        started == true
    }

    open var animationDelay: TimeInterval? = 0.1
    override open func readyToLayout() {
        super.readyToLayout()

        obs = MKAppDelegate.shared?
            .appActivePublisher
            .sink { _ in
                self.resumeAnimtion()
            }

        DispatchQueue.mainAsync(after: animationDelay) { [weak self] in
            if let self {
                startAnimation()
            }
        }
    }

    open func startAnimation() {
        guard !running else {
            return
        }

        if readyToAnimtaion() {
            started = true
            doAnimation()
        } else {
            started = false
        }
    }

    open func stopAnimation() {
        defer {
            started = nil
        }

        guard running else {
            return
        }
        cancelAnimation()
    }

    open func resumeAnimtion() {
        if started != nil {
            stopAnimation()
            startAnimation()
        }
    }

    override open func didMoveToWindow() {
        super.didMoveToWindow()

        guard readyToAnimtaion() else {
            return
        }

        if window == nil {
            stopAnimation()
        } else {
            startAnimation()
        }
    }
}

extension MKAnimationView {
    @objc open func readyToAnimtaion() -> Bool {
        false
    }

    @objc open func doAnimation() {}

    @objc open func cancelAnimation() {}
}
