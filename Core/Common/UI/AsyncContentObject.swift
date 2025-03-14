//
//  AsyncContentObject.swift
//  MKKit
//
//  Created by MK on 2023/3/27.
//

import Foundation

// MARK: - AsyncContentObject

public protocol AsyncContentObject: NSObject {
    associatedtype T

    func assignContent(_ value: T?)
}

public extension AsyncContentObject {
    var contentCancellable: AnyCancellableType? {
        get {
            getAssociatedObject(&AssociatedKeys.kCancellable) as? AnyCancellableType
        }

        set {
            setAssociatedObject(&AssociatedKeys.kCancellable, newValue)
        }
    }

    var contentPlaceHolder: T? {
        get {
            getAssociatedObject(&AssociatedKeys.kPlaceHolder) as? T
        }

        set {
            setAssociatedObject(&AssociatedKeys.kPlaceHolder, newValue)
        }
    }

    func assignContentPublisher(publisher: AnyPublisherType<T?, Never>?) {
        guard let publisher else {
            assignContent(nil)
            return
        }

        contentCancellable = publisher.sink(receiveValue: { [weak self] in
            self?.assignContent($0 ?? self?.contentPlaceHolder)
        })
    }

    func resetContent() {
        contentCancellable = nil
        assignContent(nil)
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kPlaceHolder = 0
    static var kCancellable = 0
    static var kPublisher = 0
}

// MARK: - UIImageView + AsyncContentObject

extension UIImageView: AsyncContentObject {
    public typealias T = UIImage
    public func assignContent(_ value: T?) {
        image = value
    }
}

// MARK: - UILabel + AsyncContentObject

extension UILabel: AsyncContentObject {
    public typealias T = String
    public func assignContent(_ value: T?) {
        text = value
    }
}

// MARK: - UITextView + AsyncContentObject

extension UITextView: AsyncContentObject {
    public typealias T = String
    public func assignContent(_ value: T?) {
        text = value
    }
}

// MARK: - UIProgressView + AsyncContentObject

extension UIProgressView: AsyncContentObject {
    public typealias T = Float
    public func assignContent(_ value: T?) {
        progress = value ?? 0
    }
}
