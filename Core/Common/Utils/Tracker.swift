//
//  Tracker.swift
//
//  Created by MK on 2021/9/15.
//

import UIKit

public typealias TrackerValue = [CustomStringConvertible]

// MARK: - Tracker

public protocol Tracker {
    func track(name: String, parameters: TrackerValue?)
    func setUserProperty(name: String, value: String)
}

public extension Tracker {
    func track(name: String, value: () -> CustomStringConvertible) {
        track(name: name, parameters: [value()])
    }

    func track(name: String) {
        track(name: name, parameters: [])
    }
}

public extension Bool {
    var trackSucText: String {
        self ? "success" : "failed"
    }

    var trackYesText: String {
        self ? "yes" : "no"
    }

    var trackOnText: String {
        self ? "on" : "off"
    }
}

// MARK: - TrackType

public enum TrackType: Int8 {
    case click
    case exposure
}

// MARK: - TrackInfo

public struct TrackInfo {
    public let checker: VoidFunction2<UIView, UIEdgeInsets>

    public init(checker: @escaping VoidFunction2<UIView, UIEdgeInsets>) {
        self.checker = checker
    }
}

// MARK: - TrackInfo

public extension NSObject {
    var trackInfo: TrackInfo? {
        get {
            getAssociatedObject(&AssociatedKeys.kTrackInfo) as? TrackInfo
        }
        set {
            setAssociatedObject(&AssociatedKeys.kTrackInfo, newValue)
        }
    }

    var trackSet: NSMutableSet {
        getOrMakeAssociatedObject(&AssociatedKeys.kTrackSet,
                                  type: NSMutableSet.self,
                                  builder: { .init() })
    }

    private var trackReferences: NSMutableDictionary {
        getOrMakeAssociatedObject(&AssociatedKeys.kTrackReferences,
                                  type: NSMutableDictionary.self,
                                  builder: { .init() })
    }
}

extension NSObject {
    @objc open func cleanTrackedValues() {
        trackSet.removeAllObjects()

        for value in trackReferences.allValues {
            (value as? WeakReference)?.reference?.cleanTrackedValues()
        }
    }

    @objc open func hasTracked(_ value: AnyHashable) -> Bool {
        trackSet.contains(value) || trackReferences.allKeys.contains { ($0 as? AnyHashable) == value }
    }

    @objc open func addTrack(_ value: AnyHashable, reference: NSObject?) {
        if let reference {
            trackReferences[value] = WeakReference(reference: reference)
        } else {
            trackReferences[value] = Self.nullObject
        }
    }

    private static let nullObject = NSNull()
}

extension UIView {
    @objc open func checkExposure(targetView: UIView,
                                  inset: UIEdgeInsets = .zero)
    {
        trackInfo?.checker(targetView, inset)
    }

    @objc open func checkExposure(targetView: UIView,
                                  inset: UIEdgeInsets = .zero,
                                  shouldExpose: ValueBuilder1<Bool, CGSize>,
                                  onExposure: VoidFunction1<UIView>)
    {
        let size = targetView.visibleRect(of: self, inset: inset).size
        if shouldExpose(size) {
            onExposure(self)
        }
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kTrackInfo = 0
    static var kTrackSet = 0
    static var kTrackReferences = 0
}
