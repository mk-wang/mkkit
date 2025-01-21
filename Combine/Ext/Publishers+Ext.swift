//
//  Publishers+Ext.swift
//

import Foundation

#if canImport(OpenCombine)
    import OpenCombine
#elseif canImport(Combine)
    import Combine
#endif

// MARK: - Publishers.Single

public extension Publishers {
    // https://stackoverflow.com/questions/70281648/making-custom-deffered-future-publisher-in-swift-combine
    // usage:
    // Publishers.Single<Int, Never> { result in
    //   result(Result.success(10))
    // }
    //

    struct Single<Output, Failure: Error>: Publisher {
        let promise: (@escaping (Result<Output, Failure>) -> Void) -> Void

        public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
            Deferred { Future(promise) }
                .subscribe(subscriber)
        }
    }
}

public extension Publisher {
    func single(_ promise: @escaping ((Result<Output, Failure>) -> Void) -> Void)
        -> Publishers.Single<Self.Output, Self.Failure>
    {
        Publishers.Single(promise: promise)
    }
}

public extension Publisher where Output: Equatable {
    func removeDuplicatesAndDrop(_ count: Int = 1) -> AnyPublisherType<Self.Output, Self.Failure> {
        removeDuplicates().dropFirst(count).eraseToAnyPublisher()
    }

    func removeDuplicatesDropAndDebounce(_ count: Int = 1, debounce: TimeInterval) -> AnyPublisherType<Self.Output, Self.Failure> {
        removeDuplicates().dropFirst(count).debounceOnMain(for: debounce).eraseToAnyPublisher()
    }
}

public extension Publisher {
    func debounceOnMain(for seconds: TimeInterval) -> AnyPublisherType<Self.Output, Self.Failure> {
        debounce(for: .seconds(seconds),
                 scheduler: mainScheduler)
            .eraseToAnyPublisher()
    }

    func delayOnMain(for seconds: TimeInterval) -> AnyPublisherType<Self.Output, Self.Failure> {
        delay(for: .seconds(seconds),
              scheduler: mainScheduler)
            .eraseToAnyPublisher()
    }

    func throttleOnMain(for seconds: TimeInterval, latest: Bool = true) -> AnyPublisherType<Self.Output, Self.Failure> {
        throttle(for: .seconds(seconds),
                 scheduler: mainScheduler,
                 latest: latest)
            .eraseToAnyPublisher()
    }

    func receiveOnMain() -> AnyPublisherType<Self.Output, Self.Failure> {
        receive(on: mainScheduler).eraseToAnyPublisher()
    }
}
