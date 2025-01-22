//
//  AsyncOperation.swift
//  MKKit
//
//  Created by MK on 2023/11/7.
//  from: FIRCLSAsyncOperation

import Foundation

// MARK: - AsyncOperation

open class AsyncOperation: Operation {
    private var _executing: Bool = false
    private var _finished: Bool = false

    private let lock: NSLocking = UnFairLock()

    override open var isAsynchronous: Bool {
        true
    }

    override open var isExecuting: Bool {
        defer {
            lock.unlock()
        }
        lock.lock()
        return _executing
    }

    override open var isFinished: Bool {
        defer {
            lock.unlock()
        }
        lock.lock()
        return _finished
    }

    override open func main() {
        guard !checkForCancellation() else {
            return
        }

        runTask()
    }

    override open func start() {
        guard !checkForCancellation() else {
            return
        }
        markStarted()
        main()
    }
}

extension AsyncOperation {
    func changeValue(forKey key: String, block: VoidFunction1<AsyncOperation>) {
        willChangeValue(forKey: key)
        block(self)
        didChangeValue(forKey: key)
    }

    func unlockedMarkFinish(_ value: Bool) {
        guard _finished != value else {
            return
        }
        changeValue(forKey: "isFinished") {
            $0._finished = value
        }
    }

    func unlockedMarkExecuting(_ value: Bool) {
        guard _executing != value else {
            return
        }
        changeValue(forKey: "isExecuting") {
            $0._executing = value
        }
    }

    func markDone() {
        lock.withLock { [weak self] in
            self?.unlockedMarkExecuting(false)
            self?.unlockedMarkFinish(true)
        }
    }

    func markStarted() {
        lock.withLock { [weak self] in
            self?.unlockedMarkExecuting(true)
        }
    }
}

extension AsyncOperation {
    @objc open func runTask() {}

    @objc open func checkForCancellation() -> Bool {
        if isCancelled {
            markDone()
            return true
        }
        return false
    }
}

//// MARK: - ValueOperation
//
// open class ValueOperation<T>: AsycOperation {
//    public let publisher: AnyPublisher<T, Never>
//    open private(set) var value: T
//    private var obs: Cancellable?
//    init(publisher: AnyPublisher<T, Never>, value: T) {
//        self.publisher = publisher
//        self.value = value
//
//        super.init()
//    }
//
//    override func runTask() {
//        weak var weakSelf = self
//        obs = publisher.sink {
//            weakSelf?.value = $0
//            weakSelf?.completeOperation()
//        }
//    }
// }
