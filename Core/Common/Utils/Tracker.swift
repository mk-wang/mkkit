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

public class TrackInfo {
    weak var target: UIResponder?
    var id: String?
    var onExposure: ((TrackInfo) -> Void)?
    var checkExposure: ((TrackInfo, UIScrollView) -> Void)?
}

public extension UIResponder {
    var trackInfo: TrackInfo? {
        get {
            getAssociatedObject(&AssociatedKeys.kTrackInfo) as? TrackInfo
        }
        set {
            newValue?.target = self
            setAssociatedObject(&AssociatedKeys.kTrackInfo, newValue)
        }
    }

    var trackSet: Set<String> {
        get {
            if let aSet = getAssociatedObject(&AssociatedKeys.kTrackSet) as? Set<String> {
                return aSet
            }
            let aSet = Set<String>()
            self.trackSet = aSet
            return aSet
        }
        set {
            setAssociatedObject(&AssociatedKeys.kTrackSet, newValue)
        }
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kTrackInfo = 0
    static var kTrackSet = 0
}
