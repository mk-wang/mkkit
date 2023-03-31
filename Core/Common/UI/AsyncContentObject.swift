//
//  AsyncImageView.swift
//  MKKit
//
//  Created by MK on 2023/3/27.
//

import Foundation
import OpenCombine

// MARK: - AsyncContentObject

public protocol AsyncContentObject: NSObject {
    associatedtype T

    func assignContent(_ value: T?)
}

public extension AsyncContentObject {
    var cotentCancellable: AnyCancellable? {
        get {
            getAssociatedObject(&AssociatedKeys.kCancellable) as? AnyCancellable
        }

        set {
            setAssociatedObject(&AssociatedKeys.kCancellable, newValue)
        }
    }

    var cotentPlaceHolder: T? {
        get {
            getAssociatedObject(&AssociatedKeys.kPlaceHolder) as? T
        }

        set {
            setAssociatedObject(&AssociatedKeys.kPlaceHolder, newValue)
        }
    }

    func assignContentPublisher(publisher: AnyPublisher<T?, Never>?) {
        cotentCancellable = publisher?.sink(receiveValue: { [weak self] in
            self?.assignContent($0)
        })
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
    public func assignContent(_ value: UIImage?) {
        image = value
    }
}

// MARK: - UILabel + AsyncContentObject

extension UILabel: AsyncContentObject {
    public typealias T = String
    public func assignContent(_ value: String?) {
        text = value
    }
}

// MARK: - UITextView + AsyncContentObject

extension UITextView: AsyncContentObject {
    public typealias T = String
    public func assignContent(_ value: String?) {
        text = value
    }
}
