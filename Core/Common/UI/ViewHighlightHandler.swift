//
//  ViewHighlightHandler.swift
//  MKKit
//
//  Created by MK on 2023/7/21.
//

import UIKit

// MARK: - ViewHighlightHandler

public protocol ViewHighlightHandler {
    func updateHighlightState(_: UIView, highLighted: Bool)
}

public extension UIView {
    func addHighlightHandler(_ handler: ViewHighlightHandler) {
        var list = handlers
        if list == nil {
            list = NSMutableArray()
            setAssociatedObject(&AssociatedKeys.kHandlers, list)
        }
        list?.add(handler)
    }

    func cleanHighlightHandler() {
        handlers?.removeAllObjects()
    }

    func handleHighlightState(highLighted: Bool) {
        handlers?.forEach { [weak self] in
            if let self, let handler = $0 as? ViewHighlightHandler {
                handler.updateHighlightState(self, highLighted: highLighted)
            }
        }
    }

    private var handlers: NSMutableArray? {
        getAssociatedObject(&AssociatedKeys.kHandlers) as? NSMutableArray
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kHandlers = 0
}

// MARK: - ScaleViewHighlightHandler

public struct ScaleViewHighlightHandler: ViewHighlightHandler {
    let scale: CGFloat
    let highlightDuration: TimeInterval
    let unHighlightDuration: TimeInterval

    init(scale: CGFloat = 0.90,
         highlightDuration: TimeInterval = 0.05,
         unHighlightDuration: TimeInterval = 0.1)
    {
        self.scale = scale
        self.highlightDuration = highlightDuration
        self.unHighlightDuration = unHighlightDuration
    }

    public func updateHighlightState(_ view: UIView, highLighted: Bool) {
        UIView.animate(
            withDuration: highLighted ? highlightDuration : unHighlightDuration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: { [weak view] in
                view?.transform = highLighted ? CGAffineTransform(scaleX: scale, y: scale) : .identity
            }, completion: nil
        )
    }
}

// MARK: - OverlayViewHighlightHandler

open class OverlayViewHighlightHandler: ViewHighlightHandler {
    public let overlayColor: UIColor?
    private var overlay: UIView?

    private let highlightDuration: TimeInterval
    private let unHighlightDuration: TimeInterval

    public init(_ overlayColor: UIColor? = .black.withAlphaComponent(0.08),
                highlightDuration: TimeInterval = 0.1,
                unHighlightDuration: TimeInterval = 0.1)
    {
        self.overlayColor = overlayColor
        self.highlightDuration = highlightDuration
        self.unHighlightDuration = unHighlightDuration
    }

    public func updateHighlightState(_ view: UIView, highLighted: Bool) {
        if highLighted {
            overlay?.removeFromSuperview()
            overlay = nil

            let overlay = UIView(frame: view.bounds)
            overlay.backgroundColor = .clear
            view.addSubview(overlay)
            self.overlay = overlay
        }

        weak var weakSelf = self
        let target = highLighted ? overlayColor : .clear
        UIView.animate(
            withDuration: highLighted ? highlightDuration : unHighlightDuration,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                weakSelf?.overlay?.backgroundColor = target
            }, completion: { _ in
                if highLighted {
                    weakSelf?.overlay?.backgroundColor = target
                } else {
                    weakSelf?.overlay?.removeFromSuperview()
                }
            }
        )
    }
}
