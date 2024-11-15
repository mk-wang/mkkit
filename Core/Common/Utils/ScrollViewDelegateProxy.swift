//
//  ScrollViewDelegateProxy.swift
//  Pods
//
//  Created by MK on 2024/10/16.
//

// MARK: - ScrollViewDelegateProxyProtocol

import OpenCombine
import UIKit

// MARK: - ScrollViewDelegateProxyProtocol

@objc public protocol ScrollViewDelegateProxyProtocol: UIScrollViewDelegate {
    @objc optional func scrollViewOnScrollEnd(_: UIScrollView)
}

// MARK: - ScrollViewDelegateProxy

open class ScrollViewDelegateProxy: NSObject, UIScrollViewDelegate {
    weak var target: ScrollViewDelegateProxyProtocol?

    private let offsetSubject: PassthroughSubject<CGPoint, Never> = .init()
    public lazy var offsetPublisher = offsetSubject.eraseToAnyPublisher()

    private var delegates: [WeakReference]

    public init(target: ScrollViewDelegateProxyProtocol?,
                delegate: UIScrollViewDelegate? = nil)
    {
        self.target = target
        self.delegates = [target, delegate].compactMap {
            $0 == nil ? nil : .init(reference: $0!)
        }
        super.init()
    }

    open func addDelegate(_ delegate: UIScrollViewDelegate?) {
        if let delegate {
            delegates.append(.init(reference: delegate))
        }
    }

    open func removeDelegate(_ delegate: UIScrollViewDelegate?) {
        guard let delegate else { return }
        delegates.removeAll { $0.reference === delegate }
    }

    // MARK: - Message Forwarding

    override public func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }

        return findDelegate(for: aSelector) != nil
    }

    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        findDelegate(for: aSelector) ?? super.forwardingTarget(for: aSelector)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isStopped {
            scrollViewOnScrollEnd(scrollView)
        }

        if let delegate = findDelegate(for: #selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:))) {
            delegate.scrollViewDidEndDecelerating?(scrollView)
        }
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewOnScrollEnd(scrollView)

        if let delegate = findDelegate(for: #selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:))) {
            delegate.scrollViewDidEndScrollingAnimation?(scrollView)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, scrollView.isStopped {
            scrollViewOnScrollEnd(scrollView)
        }

        if let delegate = findDelegate(for: #selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:))) {
            delegate.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let delegate = findDelegate(for: #selector(UIScrollViewDelegate.scrollViewDidScroll(_:))) {
            delegate.scrollViewDidScroll?(scrollView)
        }
        offsetSubject.send(scrollView.contentOffset)
    }

    open func scrollViewOnScrollEnd(_ scrollView: UIScrollView) {
        target?.scrollViewOnScrollEnd?(scrollView)
    }

    private func findDelegate(for selector: Selector) -> UIScrollViewDelegate? {
        delegates.compactMap { $0.reference as? UIScrollViewDelegate }
            .first { $0.responds(to: selector) }
    }
}

// MARK: - CollectionViewDelegateProxy

open class CollectionViewDelegateProxy: ScrollViewDelegateProxy, UICollectionViewDelegate {}

// MARK: - TableViewDelegate

open class TableViewDelegate: ScrollViewDelegateProxy, UITableViewDelegate {}
