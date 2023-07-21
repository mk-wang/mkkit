//
//  UIProgressViewExt.swift
//  MKKit
//
//  Created by MK on 2023/7/17.
//

import OpenCombine
import UIKit

// MARK: - ProgressObject

public protocol ProgressObject: NSObject {
    var progress: Float {
        get
        set
    }
}

public extension ProgressObject {
    func update(progress: Float, duration: TimeInterval, fps: Float = 50, callback: @escaping (Int, Int) -> Void) {
        progressTimer = nil

        let count = ceil(Float(duration) * fps)
        let countInt = Int(count)
        let diff = (progress - self.progress) / count
        var index = 0
        let timer = SwiftTimer(interval: .milliseconds(Int(Float(1000) / fps)),
                               repeats: true)
        { [weak self] _ in
            self?.progress += diff

            index += 1
            if index >= countInt {
                self?.stopUpdate()
            }
            callback(index, countInt)
        }
        timer.start()
        progressTimer = timer
    }

    func stopUpdate() {
        progressTimer = nil
    }
}

private extension ProgressObject {
    var progressTimer: SwiftTimer? {
        get {
            getAssociatedObject(&AssociatedKeys.kProgressTimer) as? SwiftTimer
        }

        set {
            setAssociatedObject(&AssociatedKeys.kProgressTimer, newValue)
        }
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kProgressTimer = 0
}

// MARK: - UIProgressView + SS

public extension UIProgressView {
    func corner(radius: CGFloat) {
        layer.cornerRadius = radius
        clipsToBounds = true
        if let sublayer = layer.sublayers?.at(1) {
            sublayer.cornerRadius = radius
        }
        if let subview = subviews.at(1) {
            subview.clipsToBounds = true
        }
    }
}

// MARK: - UIProgressView + ProgressObject

extension UIProgressView: ProgressObject {}
