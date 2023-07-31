//
//  https://www.swiftbysundell.com/articles/property-wrappers-in-swift/
//

import Foundation
import OpenCombine

// MARK: - KVStorageProperty

@propertyWrapper
public struct KVStorageProperty<T: KVStorageSerializable> {
    private let storage: KVStorage
    private let subject: CurrentValueSubject<T, Never>
    var cancellable: AnyCancellable?

    /// The key for the value in `KVStorage`.
    public let key: String

    /// The value retrieved from `KVStorage`.
    public var wrappedValue: T {
        get {
            subject.value
        }

        set {
            subject.value = newValue
        }
    }

    public var value: T {
        get {
            subject.value
        }

        set {
            subject.value = newValue
        }
    }

    /// A publisher that delivers updates to subscribers.
    public var projectedValue: CurrentValueSubject<T, Never> {
        subject
    }

    /// Initializes the property wrapper.
    /// - Parameters:
    ///   - wrappedValue: The default value to register for the specified key.
    ///   - key: The key for the value in `KVStorage`.
    ///   - storage: The `KVStorage` backing store.
    public init(wrappedValue: T, key: String, storage: KVStorage) {
        self.key = key
        self.storage = storage

        let value = storage.getSerializable(for: key) ?? wrappedValue
        subject = CurrentValueSubject<T, Never>(value)

        cancellable = subject.dropFirst().sink(receiveValue: { newValue in
            storage.saveSerializable(newValue, for: key)
        })
    }
}

// MARK: - KVStorageOptionalProperty

@propertyWrapper
public struct KVStorageOptionalProperty<T: KVStorageSerializable> {
    private let storage: KVStorage
    private let subject: CurrentValueSubject<T?, Never>
    var cancellable: AnyCancellable?

    /// The key for the value in `KVStorage`.
    public let key: String

    /// The value retrieved from `KVStorage`.
    public var wrappedValue: T? {
        get {
            subject.value
        }

        set {
            subject.value = newValue
        }
    }
    
    public var value: T? {
        get {
            subject.value
        }
        
        set {
            subject.value = newValue
        }
    }

    /// A publisher that delivers updates to subscribers.
    public var projectedValue: CurrentValueSubject<T?, Never> {
        subject
    }

    /// Initializes the property wrapper.
    /// - Parameters:
    ///   - wrappedValue: The default value to register for the specified key.
    ///   - key: The key for the value in `KVStorage`.
    ///   - storage: The `KVStorage` backing store.
    public init(key: String, storage: KVStorage) {
        self.key = key
        self.storage = storage

        let value: T? = storage.getSerializable(for: key)
        subject = CurrentValueSubject<T?, Never>(value)

        cancellable = subject.dropFirst().sink(receiveValue: { newValue in
            if let newValue {
                storage.saveSerializable(newValue, for: key)
            } else {
                storage.remove(for: key)
            }
        })
    }
}
