//
//  UIProgressViewExt.swift
//  MKKit
//
//  Created by MK on 2023/7/17.
//

import UIKit

// MARK: - FloatValue

public protocol FloatValue {
    var floatValue: Float { get set }
    static func from(value: Float) -> Self
}

// MARK: - ProgressObject

public protocol ProgressObject: NSObject {
    associatedtype T: FloatValue
    var progress: T {
        get
        set
    }
}

// MARK: - CGFloat + FloatValue

extension CGFloat: FloatValue {
    public var floatValue: Float {
        get {
            Float(self)
        }

        set {
            self = CGFloat(newValue)
        }
    }

    public static func from(value: Float) -> CGFloat {
        CGFloat(value)
    }
}

// MARK: - Float + FloatValue

extension Float: FloatValue {
    public var floatValue: Float {
        get {
            Float(self)
        }

        set {
            self = Float(newValue)
        }
    }

    public static func from(value: Float) -> Float {
        Float(value)
    }
}

// MARK: - Double + FloatValue

extension Double: FloatValue {
    public var floatValue: Float {
        get {
            Float(self)
        }

        set {
            self = Double(newValue)
        }
    }

    public static func from(value: Float) -> Double {
        Double(value)
    }
}

public extension ProgressObject {
    func update(target: Float,
                duration: TimeInterval,
                fps: Float = 50,
                progress: ((Int, Int) -> Void)? = nil,
                completion: (() -> Void)? = nil)
    {
        progressTimer = nil

        let count = ceil(Float(duration) * fps)
        let countInt = Int(count)
        let diff = (target - self.progress.floatValue) / count
        var index = 0
        let timer = SwiftTimer(interval: .milliseconds(Int(Float(1000) / fps)),
                               repeats: true)
        { [weak self] _ in
            guard let self else {
                return
            }
            let target: Float = diff + self.progress.floatValue
            self.progress = T.from(value: target)

            index += 1
            if index >= countInt {
                stopUpdate()
                if let completion {
                    DispatchQueue.mainAsync(after: TimeInterval(1 / fps)) {
                        completion()
                    }
                }
            }
            progress?(index, countInt)
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
