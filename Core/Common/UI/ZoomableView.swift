//
//  ZoomableView.swift
//  MKKit
//
//  Created by MK on 2023/8/18.
//

import UIKit

// MARK: - ZoomableView

open class ZoomableView: UIView {
    public struct Config {
        public let zoomScale: CGFloat
        public let zoomInDuratin: CGFloat
        public let zoomOutDuratin: CGFloat

        public init(zoomScale: CGFloat, zoomInDuratin: CGFloat, zoomOutDuratin: CGFloat) {
            self.zoomScale = zoomScale
            self.zoomInDuratin = zoomInDuratin
            self.zoomOutDuratin = zoomOutDuratin
        }
    }

    public static var defalutConfig: Config = .init(zoomScale: 1.3, zoomInDuratin: 0.15, zoomOutDuratin: 0.1)

    public let config: Config

    open var onTouchDown: VoidFunction?
    open var onTouchUp: VoidFunction?

    public var needZoomOut: Bool = false
    public var isAnimating = false

    public init(frame: CGRect, config: Config? = nil) {
        self.config = config ?? Self.defalutConfig
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        config = Self.defalutConfig
        super.init(coder: coder)
    }

    open func startAnimation(zoomIn: Bool) {
        let target = zoomIn ? CGAffineTransform(scaleX: config.zoomScale, y: config.zoomScale) : .identity
        let duration = zoomIn ? config.zoomInDuratin : config.zoomOutDuratin
        isAnimating = true
        weak var weakSelf = self
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: [.curveEaseInOut, .beginFromCurrentState],
                       animations: { weakSelf?.transform = target })
        { _ in
            weakSelf?.isAnimating = false
            weakSelf?.checkZoomOut()
        }
    }

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        needZoomOut = false
        startAnimation(zoomIn: true)
        onTouchDown?()
    }

    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        pendZoomOut()

        if let onTouchUp,
           event?.type == .touches,
           let touch = touches.first,
           bounds.contains(touch.location(in: self))
        {
            onTouchUp()
        }
    }

    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        pendZoomOut()
    }

    open func pendZoomOut() {
        if isAnimating {
            needZoomOut = true
        } else {
            startAnimation(zoomIn: false)
        }
    }

    open func checkZoomOut() {
        guard needZoomOut else {
            return
        }
        needZoomOut = false
        startAnimation(zoomIn: false)
    }
}

// MARK: - ZoomableImageView

open class ZoomableImageView: ZoomableView {
    private lazy var imageView = UIImageView()

    open var imageBuilder: ((Bool) -> UIImage?)?
    open var isSelected: Bool = false {
        didSet {
            self.image = imageBuilder?(isSelected)
        }
    }

    open var image: UIImage? {
        get {
            imageView.image
        }

        set {
            imageView.image = newValue
        }
    }

    override open var contentMode: UIView.ContentMode {
        get {
            imageView.contentMode
        }
        set {
            imageView.contentMode
        }
    }

    override public init(frame: CGRect, config: ZoomableView.Config? = nil) {
        super.init(frame: frame, config: config)
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.pinEdges(to: self)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func startAnimation(zoomIn: Bool) {
        super.startAnimation(zoomIn: zoomIn)
        image = imageBuilder?(zoomIn || isSelected)
    }
}
