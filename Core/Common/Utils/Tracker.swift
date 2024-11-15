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

class TrackInfo {
    var exposure: VoidFunction2<UIView, UIEdgeInsets?>?
    var click: VoidFunction1<NSObject?>?
}

// MARK: - TrackReference

class TrackReference {
    var set: Set<AnyHashable> = []
    var map: [AnyHashable: WeakReference] = [:]
}

// MARK: - TrackInfo

extension NSObject {
    var trackInfo: TrackInfo {
        getOrMakeAssociatedObject(&AssociatedKeys.kTrackInfo,
                                  type: TrackInfo.self,
                                  builder: {
                                      .init()
                                  })
    }

    var trackReferences: TrackReference {
        getOrMakeAssociatedObject(&AssociatedKeys.kTrackReference,
                                  type: TrackReference.self,
                                  builder: {
                                      .init()
                                  })
    }
}

extension NSObject {
    @objc open func cleanTrackedValues() {
        trackReferences.map.values.forEach { $0.reference?.cleanTrackedValues() }
        trackReferences.map.removeAll()
        trackReferences.set.removeAll()
    }

    @objc open func isTracked(_ value: AnyHashable) -> Bool {
        trackReferences.set.contains(value) || trackReferences.map.keys.contains(value)
    }

    @objc open func addTracking(_ value: AnyHashable, reference: NSObject? = nil) {
        if let reference {
            trackReferences.map[value] = WeakReference(reference: reference)
        } else {
            trackReferences.set.insert(value)
        }
    }
}

public extension UIResponder {
    func checkExposure(targetView: UIView,
                       inset: UIEdgeInsets? = nil)
    {
        trackInfo.exposure?(targetView, inset)
    }

    func triggerClicK() {
        trackInfo.click?(self)
    }

    func configureExposure(_ exposure: VoidFunction2<UIView, UIEdgeInsets?>?) {
        trackInfo.exposure = exposure
    }

    func configureClick(_ click: VoidFunction1<NSObject?>?) {
        trackInfo.click = click
    }
}

public extension UIView {
    func checkExposure(targetView: UIView,
                       inset: UIEdgeInsets? = nil,
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
    static var kTrackReference = 0
}
