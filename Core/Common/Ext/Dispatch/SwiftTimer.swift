//
//  SwiftTimer.swift
//  SwiftTimer
//
//  Created by mangofang on 16/8/23.
//  https://github.com/100mango/SwiftTimer/blob/master/Sources/SwiftTimer.swift
//

import Foundation

// MARK: - SwiftTimer

public class SwiftTimer {
    private let internalTimer: DispatchSourceTimer

    public private(set) var isRunning = false

    public let repeats: Bool

    public typealias SwiftTimerHandler = (SwiftTimer) -> Void

    private var handler: SwiftTimerHandler

    public init(interval: DispatchTimeInterval,
                delay: DispatchTimeInterval? = nil,
                repeats: Bool = false,
                leeway: DispatchTimeInterval = .seconds(0),
                queue: DispatchQueue = .main,
                handler: @escaping SwiftTimerHandler)
    {
        self.handler = handler
        self.repeats = repeats
        internalTimer = DispatchSource.makeTimerSource(queue: queue)
        internalTimer.setEventHandler { [weak self] in
            if let self {
                handler(self)
            }
        }

        if repeats {
            internalTimer.schedule(deadline: .now() + (delay ?? interval),
                                   repeating: interval,
                                   leeway: leeway)
        } else {
            internalTimer.schedule(deadline: .now() + interval,
                                   leeway: leeway)
        }
    }

    public convenience init(interval: TimeInterval,
                            delay: TimeInterval? = nil,
                            repeats: Bool = false,
                            leeway: TimeInterval = 0,
                            queue: DispatchQueue = .main,
                            handler: @escaping SwiftTimerHandler)
    {
        self.init(interval: .fromSeconds(interval),
                  delay: delay == nil ? nil : .fromSeconds(delay!),
                  repeats: repeats,
                  leeway: .fromSeconds(leeway),
                  queue: queue,
                  handler: handler)
    }

    public static func repeaticTimer(interval: DispatchTimeInterval, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main, handler: @escaping SwiftTimerHandler) -> SwiftTimer {
        SwiftTimer(interval: interval, repeats: true, leeway: leeway, queue: queue, handler: handler)
    }

    deinit {
        if !self.isRunning {
            internalTimer.resume()
        }
    }

    // You can use this method to fire a repeating timer without interrupting its regular firing schedule. If the timer is non-repeating, it is automatically invalidated after firing, even if its scheduled fire date has not arrived.
    public func fire() {
        if repeats {
            handler(self)
        } else {
            handler(self)
            internalTimer.cancel()
        }
    }

    public func start() {
        if !isRunning {
            internalTimer.resume()
            isRunning = true
        }
    }

    public func suspend() {
        if isRunning {
            internalTimer.suspend()
            isRunning = false
        }
    }

    public func rescheduleRepeating(interval: DispatchTimeInterval) {
        if repeats {
            internalTimer.schedule(deadline: .now() + interval, repeating: interval)
        }
    }

    public func rescheduleHandler(handler: @escaping SwiftTimerHandler) {
        self.handler = handler
        internalTimer.setEventHandler { [weak self] in
            if let self {
                handler(self)
            }
        }
    }
}

// MARK: Throttle

public extension SwiftTimer {
    private static var workItems = [String: DispatchWorkItem]()

    /// The Handler will be called after interval you specified
    /// Calling again in the interval cancels the previous call
    static func debounce(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        // if already exist
        if let item = workItems[identifier] {
            item.cancel()
        }

        let item = DispatchWorkItem {
            handler()
            workItems.removeValue(forKey: identifier)
        }
        workItems[identifier] = item
        queue.asyncAfter(deadline: .now() + interval, execute: item)
    }

    /// The Handler will be called after interval you specified
    /// It is invalid to call again in the interval
    static func throttle(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main, handler: @escaping () -> Void) {
        // if already exist
        if workItems[identifier] != nil {
            return
        }

        let item = DispatchWorkItem {
            handler()
            workItems.removeValue(forKey: identifier)
        }
        workItems[identifier] = item
        queue.asyncAfter(deadline: .now() + interval, execute: item)
    }

    static func cancelThrottlingTimer(identifier: String) {
        if let item = workItems[identifier] {
            item.cancel()
            workItems.removeValue(forKey: identifier)
        }
    }
}

// MARK: - SwiftCountDownTimer

public class SwiftCountDownTimer {
    private let internalTimer: SwiftTimer

    private var leftTimes: Int

    private let originalTimes: Int

    private let handler: (SwiftCountDownTimer, _ leftTimes: Int) -> Void

    public init(interval: DispatchTimeInterval, times: Int, queue: DispatchQueue = .main, handler: @escaping (SwiftCountDownTimer, _ leftTimes: Int) -> Void) {
        leftTimes = times
        originalTimes = times
        self.handler = handler
        internalTimer = SwiftTimer.repeaticTimer(interval: interval, queue: queue, handler: { _ in
        })
        internalTimer.rescheduleHandler { [weak self] _ in
            guard let self else {
                return
            }
            if leftTimes > 0 {
                leftTimes = leftTimes - 1
                self.handler(self, leftTimes)
            } else {
                internalTimer.suspend()
            }
        }
    }

    public func start() {
        internalTimer.start()
    }

    public func suspend() {
        internalTimer.suspend()
    }

    public func reCountDown() {
        leftTimes = originalTimes
    }
}

public extension DispatchTimeInterval {
    static func fromSeconds(_ seconds: Double) -> DispatchTimeInterval {
        .milliseconds(Int(seconds * 1000))
    }
}
