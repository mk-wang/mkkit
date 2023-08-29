//
//  BoolMerge.swift
//  MKKit
//
//  Created by MK on 2023/8/28.
//

import Foundation
import OpenCombine

// MARK: - BoolMerge

public class BoolMerge: Publisher {
    public typealias Output = Bool
    public typealias Failure = Never

    var cancellableSet = Set<AnyCancellable>()
    var values: [Bool]

    let subjuct = CurrentValueSubject<Bool, Never>(false)

    var value: Bool {
        get {
            subjuct.value
        }

        set {
            if subjuct.value != newValue {
                subjuct.value = newValue
            }
        }
    }

    public init(_ list: [some OpenCombine.Publisher<Bool, Never>]) {
        values = Array(repeating: false, count: list.count)

        for (index, publihser) in list.enumerated() {
            publihser.sink { [weak self] in
                self?.values[index] = $0
                self?.checkValues()
            }.store(in: &cancellableSet)
        }
    }

    public func receive<Subscriber>(subscriber: Subscriber) where Subscriber: OpenCombine.Subscriber, Never == Subscriber.Failure, Bool == Subscriber.Input {
        subjuct.subscribe(subscriber)
    }

    func checkValues() {
        for value in values {
            if !value {
                self.value = false
                return
            }
        }
        value = true
    }
}

//
//// MARK: - BoolMerge
//
// public extension Publisher where Output == Bool, Failure == Never {
//    func boolMerge(_ A: Self) -> AnyPublisher<Bool, Never> {
//        BoolMerge([self, A]).eraseToAnyPublisher()
//    }
//
//    func boolMerge(_ A: Self, _ B: Self) -> AnyPublisher<Bool, Never> {
//        BoolMerge([self, A, B]).eraseToAnyPublisher()
//    }
//
//    func boolMerge(_ A: Self, _ B: Self, _ C: Self) -> AnyPublisher<Bool, Never> {
//        BoolMerge([self, A, B, C]).eraseToAnyPublisher()
//    }
//
//    func boolMerge(_ list: [Self]) -> AnyPublisher<Bool, Never> {
//        var publishers = [self]
//        publishers.append(contentsOf: list)
//        return BoolMerge(publishers).eraseToAnyPublisher()
//    }
// }
