//
//  PublishersExt.swift
//

import Foundation
import OpenCombine
import OpenCombineFoundation

// MARK: - Publishers.Single

public extension Publishers {
    // https://stackoverflow.com/questions/70281648/making-custom-deffered-future-publisher-in-swift-combine
    //
    struct Single<Output, Failure: Error>: Publisher {
        let promise: (@escaping (Result<Output, Failure>) -> Void) -> Void

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            Deferred { Future(promise) }
                .subscribe(subscriber)
        }
    }
}

public extension Publisher where Output: Equatable {
    func removeDuplicatesAndDropFirst(_ count: Int = 1) -> AnyPublisher<Self.Output, Self.Failure> {
        removeDuplicates().dropFirst(count).eraseToAnyPublisher()
    }
}

public extension Publisher {
    func debounceOnMain(for seconds: TimeInterval) -> AnyPublisher<Self.Output, Self.Failure> {
        debounce(for: RunLoop.OCombine.SchedulerTimeType.Stride(seconds),
                 scheduler: RunLoop.main.ocombine)
            .eraseToAnyPublisher()
    }

    func throttleOnMain(for seconds: TimeInterval, latest: Bool = true) -> AnyPublisher<Self.Output, Self.Failure> {
        throttle(for: RunLoop.OCombine.SchedulerTimeType.Stride(seconds),
                 scheduler: RunLoop.main.ocombine,
                 latest: latest)
            .eraseToAnyPublisher()
    }
}
