//
//  LottieAnimatorObserver.swift
//
//  Created by MK on 2023/10/16.
//

import Lottie
import MKKit
import UIKit

public class LottieAnimatorObserver {
    public typealias ProgressChangeBlock = (_ progress: CGFloat) -> Void

    private var displayLink: CADisplayLink?

    private weak var animationView: LottieAnimationView?
    public var onProgressChanged: ProgressChangeBlock?
    private var lastProgress: CGFloat = -1

    public init(animationView: LottieAnimationView, onProgressChanged: ProgressChangeBlock?) {
        self.animationView = animationView
        self.onProgressChanged = onProgressChanged
    }

    deinit {
        invalidate()
    }

    public func prepare() {
        guard onProgressChanged != nil else {
            displayLink?.invalidate()
            displayLink = nil
            return
        }

        let proxy = WeakProxy(target: self)
        displayLink = CADisplayLink(target: proxy, selector: #selector(displayLinkTick))
        displayLink?.add(to: RunLoop.current, forMode: .common)
    }

    public func invalidate() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func displayLinkTick() {
        guard let animation = animationView, let onChange = onProgressChanged else {
            return
        }

        if animation.isAnimationPlaying {
            let progress = animation.realtimeAnimationProgress
            if progress != lastProgress {
                onChange(progress)
                lastProgress = progress
            }
        }
    }
}
