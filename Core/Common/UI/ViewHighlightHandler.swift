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
        let list = getOrMakeAssociatedObject(&AssociatedKeys.kHandlers,
                                             type: NSMutableArray.self,
                                             builder: { .init() })
        list.add(handler)
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
    public let scale: CGFloat
    public let highlightDuration: TimeInterval
    public let unHighlightDuration: TimeInterval

    public init(scale: CGFloat = 0.95,
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
    public let highlightDuration: TimeInterval
    public let unHighlightDuration: TimeInterval

    private weak var overlay: UIView?

    public init(_ overlayColor: UIColor? = .black.withAlphaComponent(0.08),
                highlightDuration: TimeInterval = 0.1,
                unHighlightDuration: TimeInterval = 0.1)
    {
        self.overlayColor = overlayColor
        self.highlightDuration = highlightDuration
        self.unHighlightDuration = unHighlightDuration
    }

    deinit {
        overlay?.removeFromSuperview()
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
