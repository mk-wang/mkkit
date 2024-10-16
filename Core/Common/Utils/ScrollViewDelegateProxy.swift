//
//  ScrollViewDelegateProxy.swift
//  Pods
//
//  Created by MK on 2024/10/16.
//

// MARK: - ScrollViewDelegateProxyProtocol

import UIKit

// MARK: - ScrollViewDelegateProxyProtocol

@objc public protocol ScrollViewDelegateProxyProtocol: UIScrollViewDelegate {
    @objc optional func scrollViewOnScrollEnd(_: UIScrollView)
}

// MARK: - ScrollViewDelegateProxy

open class ScrollViewDelegateProxy: NSObject, UIScrollViewDelegate {
    weak var target: ScrollViewDelegateProxyProtocol?

    public init(target: ScrollViewDelegateProxyProtocol?) {
        self.target = target
        super.init()
    }

    // MARK: - Message Forwarding

    override public func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        return target?.responds(to: aSelector) ?? false
    }

    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        if target?.responds(to: aSelector) == true {
            return target
        }
        return super.forwardingTarget(for: aSelector)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.isStopped {
            scrollViewOnScrollEnd(scrollView)
        }
        target?.scrollViewDidEndDecelerating?(scrollView)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewOnScrollEnd(scrollView)
        target?.scrollViewDidEndScrollingAnimation?(scrollView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate, scrollView.isStopped {
            scrollViewOnScrollEnd(scrollView)
        }

        target?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    open func scrollViewOnScrollEnd(_ scrollView: UIScrollView) {
        target?.scrollViewOnScrollEnd?(scrollView)
    }
}

// MARK: - CollectionViewDelegateProxy

open class CollectionViewDelegateProxy: ScrollViewDelegateProxy, UICollectionViewDelegate {}

// MARK: - TableViewDelegate

open class TableViewDelegate: ScrollViewDelegateProxy, UITableViewDelegate {}
