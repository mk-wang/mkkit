//
//  ScrollViewDelegateProxy.swift
//  Pods
//
//  Created by MK on 2024/10/16.
//

import UIKit

// MARK: - ScrollViewDelegateProxy

open class ScrollViewDelegateProxy: NSObject, UIScrollViewDelegate {
    private let offsetSubject: CurrentValueSubject<CGPoint, Never> = .init(.zero)
    public lazy var offsetPublisher = offsetSubject.eraseToAnyPublisher()

    private let scrollEndSubject: PassthroughSubject<Void, Never> = .init()
    public lazy var scrollEndPublisher = scrollEndSubject.eraseToAnyPublisher()

    private var delegates: [WeakReference] = []

    public init(delegate: UIScrollViewDelegate? = nil) {
        super.init()
        addDelegate(delegate)
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

        forwardSelector(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:)),
                        scrollView: scrollView)
        {
            $0.scrollViewDidEndDecelerating?($1)
        }
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewOnScrollEnd(scrollView)

        forwardSelector(#selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:)),
                        scrollView: scrollView)
        {
            $0.scrollViewDidEndScrollingAnimation?($1)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, scrollView.isStopped {
            scrollViewOnScrollEnd(scrollView)
        }

        findDelegate(for: #selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:)))?
            .scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        forwardSelector(#selector(UIScrollViewDelegate.scrollViewDidScroll(_:)),
                        scrollView: scrollView)
        {
            $0.scrollViewDidScroll?($1)
        }

        offsetSubject.send(scrollView.contentOffset)
    }

    open func scrollViewOnScrollEnd(_: UIScrollView) {
        scrollEndSubject.send(())
    }

    private func findDelegate(for selector: Selector) -> UIScrollViewDelegate? {
        cleanUpDelegates()
        return delegates.compactMap { $0.reference as? UIScrollViewDelegate }
            .first { $0.responds(to: selector) }
    }

    func forwardSelector(_ selector: Selector,
                         scrollView: UIScrollView,
                         fallback: ((UIScrollViewDelegate, UIScrollView) -> Void)? = nil)
    {
        guard let delegate = findDelegate(for: selector) else {
            return
        }

        guard let method = (delegate as? NSObject)?.method(for: selector) else {
            fallback?(delegate, scrollView)
            return
        }

        typealias FunctionType = @convention(c) (Any, Selector, UIScrollView) -> Void
        let implementation = unsafeBitCast(method, to: FunctionType.self)
        implementation(delegate, selector, scrollView)
    }

    private func cleanUpDelegates() {
        delegates.removeAll { $0.reference == nil }
    }
}

// MARK: - CollectionViewDelegateProxy

open class CollectionViewDelegateProxy: ScrollViewDelegateProxy, UICollectionViewDelegate {}

// MARK: - TableViewDelegate

open class TableViewDelegate: ScrollViewDelegateProxy, UITableViewDelegate {}
