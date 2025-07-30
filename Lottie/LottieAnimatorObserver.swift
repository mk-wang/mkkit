//
//  LottieAnimatorObserver.swift
//
//  Created by MK on 2023/10/16.
//

import Lottie
import UIKit

#if Lottie_3
    public typealias LottieAnimationView = Lottie.AnimationView
    public typealias LottieAnimation = Lottie.Animation
#endif

// MARK: - LottieAnimatorObserver

public class LottieAnimatorObserver {
    public typealias ProgressChangeBlock = (_ progress: CGFloat) -> Void
    public typealias FrameTimeChangeBlock = (_ frame: CGFloat) -> Void

    private var displayLink: CADisplayLink?

    private weak var animationView: LottieAnimationView?
    public var onProgressChanged: ProgressChangeBlock?
    public var onFrameChanged: FrameTimeChangeBlock?

    private var lastProgress: CGFloat = -1
    private var lastFrame: CGFloat = -1

    public init(animationView: LottieAnimationView,
                onProgressChanged: ProgressChangeBlock? = nil,
                onFrameChanged: FrameTimeChangeBlock? = nil)
    {
        self.animationView = animationView
        self.onFrameChanged = onFrameChanged
        self.onProgressChanged = onProgressChanged
    }

    deinit {
        stop()
    }

    private var needObserve: Bool {
        onProgressChanged != nil || onFrameChanged != nil
    }

    public func start() {
        guard needObserve else {
            displayLink?.invalidate()
            displayLink = nil
            return
        }

        let proxy = WeakProxy(target: self)
        displayLink = CADisplayLink(target: proxy, selector: #selector(displayLinkTick))
        displayLink?.add(to: RunLoop.current, forMode: .common)
    }

    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func displayLinkTick() {
        guard let animation = animationView, needObserve else {
            return
        }

        if animation.isAnimationPlaying {
            if let onProgressChanged {
                let progress = animation.realtimeAnimationProgress
                if progress != lastProgress {
                    onProgressChanged(progress)
                    lastProgress = progress
                }
            }
            if let onFrameChanged {
                let frame = animation.realtimeAnimationFrame
                if frame != lastFrame {
                    onFrameChanged(frame)
                    lastFrame = frame
                }
            }
        }
    }
}
