//
//  BoolMerge.swift
//  MKKit
//
//  Created by MK on 2023/8/28.
//

import Foundation

#if canImport(OpenCombine)
    import OpenCombine
    import OpenCombineDispatch
    import OpenCombineFoundation

    public typealias PublisherType = OpenCombine.Publisher
    public typealias SubscriberType = OpenCombine.Subscriber
    public typealias CurrentValueSubjectType = OpenCombine.CurrentValueSubject
    public typealias PassthroughSubjectType = OpenCombine.PassthroughSubject

    public typealias AnyCancellableType = OpenCombine.AnyCancellable
    public typealias AnyPublisherType = OpenCombine.AnyPublisher

    public let notificationCenter = NotificationCenter.default.ocombine
    public let mainScheduler = DispatchQueue.main.ocombine

#elseif canImport(Combine)
    import Combine

    public typealias PublisherType = Combine.Publisher
    public typealias SubscriberType = Combine.Subscriber
    public typealias CurrentValueSubjectType = Combine.CurrentValueSubject
    public typealias PassthroughSubjectType = Combine.PassthroughSubject

    public typealias AnyCancellableType = Combine.AnyCancellable
    public typealias AnyPublisherType = Combine.AnyPublisher

    public let notificationCenter = NotificationCenter.default
    public let mainScheduler = DispatchQueue.main

#endif

// MARK: - BoolMerge

// wait for all
public class BoolMerge: Publisher {
    public typealias Output = Bool
    public typealias Failure = Never

    public enum Operate {
        case and
        case or
    }

    var cancellableSet = Set<AnyCancellableType>()
    var values: [Bool]

    let subjuct = CurrentValueSubjectType<Bool, Never>(false)
    let operate: Operate

    public var onValuesUpdate: VoidFunction1<[Bool]>?

    public private(set) var value: Bool {
        get {
            subjuct.value
        }

        set {
            if subjuct.value != newValue {
                subjuct.value = newValue
            }
        }
    }

    public init(_ list: [some PublisherType<Bool, Never>], operate: Operate = .and) {
        self.operate = operate

        values = Array(repeating: false, count: list.count)

        for (index, publihser) in list.enumerated() {
            publihser.sink { [weak self] in
                self?.update(value: $0, index: index)
            }.store(in: &cancellableSet)
        }
    }

    public func receive<Subscriber>(subscriber: Subscriber) where Subscriber: SubscriberType,
        Never == Subscriber.Failure,
        Bool == Subscriber.Input
    {
        subjuct.subscribe(subscriber)
    }

    private func update(value: Bool, index: Int) {
        values[index] = value

        onValuesUpdate?(values)

        if operate == .and {
            for value in values {
                if !value {
                    self.value = false
                    return
                }
            }
            self.value = true
        } else {
            for value in values {
                if value {
                    self.value = true
                    return
                }
            }
            self.value = false
        }
    }
}
