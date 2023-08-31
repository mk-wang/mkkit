//
//  Publishers+Ext.swift
//

import Foundation
import OpenCombine
import OpenCombineDispatch

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
    func removeDuplicatesAndDropFirst(_ count: Int = 1) -> AnyPublisher<Self.Output, Self.Failure> {
        removeDuplicates().dropFirst(count).eraseToAnyPublisher()
    }
}

public extension Publisher {
    func debounceOnMain(for seconds: TimeInterval) -> AnyPublisher<Self.Output, Self.Failure> {
        debounce(for: .seconds(seconds),
                 scheduler: DispatchQueue.main.ocombine)
            .eraseToAnyPublisher()
    }

    func delayOnMain(for seconds: TimeInterval) -> AnyPublisher<Self.Output, Self.Failure> {
        delay(for: .seconds(seconds),
              scheduler: DispatchQueue.main.ocombine)
            .eraseToAnyPublisher()
    }

    func throttleOnMain(for seconds: TimeInterval, latest: Bool = true) -> AnyPublisher<Self.Output, Self.Failure> {
        throttle(for: .seconds(seconds),
                 scheduler: DispatchQueue.main.ocombine,
                 latest: latest)
            .eraseToAnyPublisher()
    }

    func receiveOnMain() -> AnyPublisher<Self.Output, Self.Failure> {
        receive(on: DispatchQueue.main.ocombine).eraseToAnyPublisher()
    }
}
