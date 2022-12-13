//
//  SwiftTimer.swift
//  SwiftTimer
//
//  Created by mangofang on 16/8/23.
//  https://github.com/100mango/SwiftTimer/blob/master/Sources/SwiftTimer.swift
//
// 当Timer创建完后，建议调用activate()方法开始运行。如果直接调用resume()也可以开始运行。
// suspend()的时候，并不会停止当前正在执行的event事件，而是会停止下一次event事件。
// 当Timer处于suspend的状态时，如果销毁Timer或其所属的控制器，会导致APP奔溃。
// suspend()和resume()需要成对出现，挂起一次，恢复一次，如果Timer开始运行后，在没有suspend的时候，直接调用resume()，会导致APP崩溃。
// 使用cancel()的时候，如果Timer处于suspend状态，APP崩溃。
// 另外需要注意block的循环引用问题。
//
// ————————————————
// 版权声明：本文为CSDN博主「Daniel_Coder」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
// 原文链接：https://blog.csdn.net/guoyongming925/article/details/110224064

import Foundation

// MARK: - SwiftTimer

public class SwiftTimer {
    private let internalTimer: DispatchSourceTimer

    private var isRunning = false

    public let repeats: Bool

    public typealias SwiftTimerHandler = (SwiftTimer) -> Void

    private var handler: SwiftTimerHandler

    public init(interval: DispatchTimeInterval, repeats: Bool = false, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main, handler: @escaping SwiftTimerHandler) {
        self.handler = handler
        self.repeats = repeats
        internalTimer = DispatchSource.makeTimerSource(queue: queue)
        internalTimer.setEventHandler { [weak self] in
            if let strongSelf = self {
                handler(strongSelf)
            }
        }

        if repeats {
            internalTimer.schedule(deadline: .now() + interval, repeating: interval, leeway: leeway)
        } else {
            internalTimer.schedule(deadline: .now() + interval, leeway: leeway)
        }
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
            if let strongSelf = self {
                handler(strongSelf)
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

// MARK: Count Down

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
            if let strongSelf = self {
                if strongSelf.leftTimes > 0 {
                    strongSelf.leftTimes = strongSelf.leftTimes - 1
                    strongSelf.handler(strongSelf, strongSelf.leftTimes)
                } else {
                    strongSelf.internalTimer.suspend()
                }
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
