//
//  DispatchQueueExt.swift
//
//
//  Created by MK on 2021/5/26.
//

import Foundation

public extension DispatchQueue {
    static var currentQueueLabel: String? {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8)
    }

    @inline(__always) class func async(queue: DispatchQueue,
                                       after interval: TimeInterval? = nil,
                                       block: @escaping () -> Void)
    {
        if let interval, interval > 0 {
            queue.asyncAfter(deadline: DispatchTime.now() + interval) {
                block()
            }
        } else {
            if Self.currentQueueLabel == queue.label {
                block()
            } else {
                queue.async(execute: block)
            }
        }
    }

    class func mainAsync(after interval: TimeInterval? = nil, block: @escaping () -> Void) {
        Self.async(queue: .main, after: interval, block: block)
    }
}
