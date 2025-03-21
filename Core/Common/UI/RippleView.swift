//
//  RippleView.swift
//  Pods
//
//  Created by MK on 2025/3/20.
//

public class RippleView: UIView {
    public struct Config {
        public let innerRadius: CGFloat
        public let outterRadius: CGFloat
        public let rippleCount: Int
        public let rippleColor: UIColor
        public let duration: CFTimeInterval
        public let initialAlpha: CGFloat

        public init(innerRadius: CGFloat,
                    outterRadius: CGFloat,
                    rippleCount: Int,
                    rippleColor: UIColor,
                    duration: CFTimeInterval,
                    initialAlpha: CGFloat)
        {
            self.innerRadius = innerRadius
            self.outterRadius = outterRadius
            self.rippleCount = rippleCount
            self.rippleColor = rippleColor
            self.duration = duration
            self.initialAlpha = initialAlpha
        }
    }

    private var rippleLayers: [CAShapeLayer] = []

    public let config: Config

    public init(frame: CGRect,
                config: Config)
    {
        self.config = config
        super.init(frame: frame)
        setupRipples()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupRipples() {
        let rippleColor = config.rippleColor

        for _ in 0 ..< config.rippleCount {
            let rippleLayer = CAShapeLayer()
            rippleLayer.fillColor = rippleColor.cgColor
            rippleLayer.strokeColor = nil
            rippleLayer.opacity = 0
            layer.addSublayer(rippleLayer)
            rippleLayers.append(rippleLayer)
        }
    }

    public func start() {
        let delay = config.duration / CFTimeInterval(config.rippleCount)
        let initialAlpha = config.initialAlpha
        for (index, layer) in rippleLayers.enumerated() {
            let key = "rippleAnimation\(index)"

            let duration = config.duration
            let innerRadius = config.innerRadius
            let outterRadius = config.outterRadius

            let startTime = CACurrentMediaTime() + delay * CFTimeInterval(index)

            let radiusAnimation = CABasicAnimation(keyPath: "path")
            radiusAnimation.fromValue = createCirclePath(radius: innerRadius)
            radiusAnimation.toValue = createCirclePath(radius: outterRadius)
            radiusAnimation.duration = duration

            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.fromValue = initialAlpha
            opacityAnimation.toValue = 0.0
            opacityAnimation.duration = duration

            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [radiusAnimation, opacityAnimation]
            animationGroup.duration = duration
            animationGroup.repeatCount = .infinity
            animationGroup.beginTime = startTime

            layer.add(animationGroup, forKey: key)
        }
    }

    public func stop() {
        rippleLayers.forEach { $0.removeAllAnimations() }
    }

    private func createCirclePath(radius: CGFloat) -> CGPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        return UIBezierPath(arcCenter: center, radius: radius,
                            startAngle: 0, endAngle: .pi * 2, clockwise: true).cgPath
    }
}
