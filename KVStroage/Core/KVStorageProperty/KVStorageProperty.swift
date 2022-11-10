//
//  https://www.swiftbysundell.com/articles/property-wrappers-in-swift/
//

import Foundation
import OpenCombine

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    fileprivate var isNil: Bool { self == nil }
}

@propertyWrapper
public struct KVStorageProperty<T: Codable> {
    private let storage: KVStorage
    private let subject: CurrentValueSubject<T, Never>

    /// The key for the value in `KVStorage`.
    public let key: String

    /// The value retrieved from `KVStorage`.
    public var wrappedValue: T {
        get {
            subject.value
        }

        set {
            if (newValue as? AnyOptional)?.isNil ?? false {
                storage.remove(for: key)
            } else {
                storage.set(newValue, for: key)
            }
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

        let value = storage.object(for: key) ?? wrappedValue
        subject = CurrentValueSubject<T, Never>(value)
    }
}

public extension KVStorageProperty where T: ExpressibleByNilLiteral {
    init(key: String, storage: KVStorage) {
        self.init(wrappedValue: nil, key: key, storage: storage)
    }
}
