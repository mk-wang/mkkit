//
//  DisplayLink.swift
//  MKKit
//
//  Created by MK on 2023/11/9.
//

import Foundation

open class DisplayLink {
    public let callback: VoidFunction3<DisplayLink, TimeInterval, TimeInterval>
    public let fps: Int

    private var displayLink: CADisplayLink?
    private var nextFireTime: TimeInterval?
    private var previousTime: TimeInterval?

    public init(fps: Int = 60,
                callback: @escaping VoidFunction3<DisplayLink, TimeInterval, TimeInterval>)
    {
        self.fps = fps
        self.callback = callback
    }

    deinit {
        stop()
    }

    open var isRunning: Bool {
        guard let displayLink else {
            return false
        }
        return !displayLink.isPaused
    }

    open var isPaused: Bool {
        displayLink?.isPaused ?? false
    }

    // 距离下次 frame 的时间
    open var duration: TimeInterval {
        var value: TimeInterval = 0
        if let nextFireTime {
            value = nextFireTime - CACurrentMediaTime()
            if value < 0 {
                value = displayLink?.duration ?? 0
            }
        }
        return value
    }

    open func pause() {
        displayLink?.isPaused = true
    }

    open func resume() {
        displayLink?.isPaused = false
    }

    open func start() {
        stop()

        let proxy = WeakProxy(target: self)
        let displayLink = CADisplayLink(target: proxy, selector: #selector(displayLinkTick))
        if #available(iOS 15.0, *) {
            let preferred = Float(fps)
            displayLink.preferredFrameRateRange = .init(minimum: preferred, maximum: preferred, preferred: preferred)
        } else {
            displayLink.preferredFramesPerSecond = fps
        }
        displayLink.add(to: RunLoop.main, forMode: .common)

        self.displayLink = displayLink
    }

    open func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func displayLinkTick(_ displayLink: CADisplayLink) {
        let target = displayLink.targetTimestamp
        nextFireTime = target

        let timestamp = displayLink.timestamp
        
        let passed = previousTime == nil ? 0 : timestamp - previousTime!
        previousTime = timestamp
        
        // 理论上经过的时间
        let interval = target - timestamp

        callback(self, passed, interval)
    }
}
