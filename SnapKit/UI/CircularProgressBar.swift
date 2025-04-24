//
//  CircularProgressBar.swift
//
//  Created by MK on 2023/8/4.
//

import Foundation
import UIKit

// MARK: - CircularProgressBar

open class CircularProgressBar: UIView {
    public struct Config {
        let lineWidth: CGFloat
        let clockwise: Bool
        let startAngle: CGFloat
        let initialProgress: Float
        let trackColor: UIColor
        let progressColor: UIColor
        let lineCap: CAShapeLayerLineCap

        public init(lineWidth: CGFloat,
                    clockwise: Bool,
                    startAngle: CGFloat,
                    initialProgress: Float,
                    trackColor: UIColor,
                    progressColor: UIColor,
                    lineCap: CAShapeLayerLineCap)
        {
            self.lineWidth = lineWidth
            self.clockwise = clockwise
            self.startAngle = startAngle
            self.initialProgress = initialProgress
            self.trackColor = trackColor
            self.progressColor = progressColor
            self.lineCap = lineCap
        }
    }

    fileprivate var progressLayer: CAShapeLayer!
    fileprivate var trackLayer: CAShapeLayer!
    fileprivate var layerSize: CGSize = .zero

    public let config: Config

    public init(frame: CGRect, config: Config) {
        self.config = config
        super.init(frame: frame)
        if !frame.isEmpty {
            createCircularPath(progress: CGFloat(config.initialProgress))
        }
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open var progress: Float {
        get {
            Float(getProgress())
        }
        set {
            UIView.runDisableActions { [weak self] in
                self?.updateProgress(progress: CGFloat(newValue))
            }
        }
    }

    private func createCircularPath(progress: CGFloat) {
        let size = bounds.size
        if layerSize != size || progressLayer == nil {
            var start = config.startAngle - CGFloat.pi / 2
            var end = config.startAngle + 2 * CGFloat.pi - CGFloat.pi / 2
            if !config.clockwise {
                swap(&start, &end)
            }
            let circularPath = UIBezierPath(arcCenter: CGPoint(x: size.width / 2, y: size.height / 2),
                                            radius: bounds.width / 2 - config.lineWidth / 2,
                                            startAngle: start,
                                            endAngle: end,
                                            clockwise: config.clockwise)

            trackLayer = CAShapeLayer()
            trackLayer.path = circularPath.cgPath
            trackLayer.fillColor = UIColor.clear.cgColor
            trackLayer.strokeColor = config.trackColor.cgColor
            trackLayer.lineWidth = config.lineWidth
            trackLayer.strokeEnd = 1.0
            layer.addSublayer(trackLayer)

            progressLayer = CAShapeLayer()
            progressLayer.path = circularPath.cgPath
            progressLayer.fillColor = UIColor.clear.cgColor
            progressLayer.strokeColor = config.progressColor.cgColor
            progressLayer.lineWidth = config.lineWidth
            progressLayer.lineCap = config.lineCap
            layer.addSublayer(progressLayer)
        }
        updateProgress(progress: progress)
        layerSize = size
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        guard !isEmptyBounds, progressLayer?.superlayer == nil else {
            return
        }
        createCircularPath(progress: CGFloat(config.initialProgress))
    }

    open func resize() {
        let progress = CGFloat(progress)
        trackLayer.removeFromSuperlayer()
        progressLayer.removeFromSuperlayer()
        createCircularPath(progress: progress)
    }

    open func setProgressWithAnimation(duration: TimeInterval, progress: Float) {
        guard progressLayer != nil else {
            return
        }

        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = CGFloat(progress)
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        progressLayer.add(animation, forKey: "animateProgress")
        progressLayer.strokeEnd = CGFloat(progress)
    }

    fileprivate func updateProgress(progress: CGFloat) {
        guard progressLayer != nil else {
            return
        }
        progressLayer.strokeEnd = progress
    }

    fileprivate func getProgress() -> CGFloat {
        guard progressLayer != nil else {
            return 0
        }
        return progressLayer.strokeEnd
    }
}

// MARK: - ReverseCircularProgressBar

open class ReverseCircularProgressBar: CircularProgressBar {
    override fileprivate func updateProgress(progress: CGFloat) {
        progressLayer.strokeEnd = 1 - progress
    }

    override func getProgress() -> CGFloat {
        1 - progressLayer.strokeEnd
    }

    override open func setProgressWithAnimation(duration: TimeInterval, progress: Float) {
        super.setProgressWithAnimation(duration: duration, progress: 1 - progress)
    }
}

// MARK: - CircularProgressBar + ProgressObject

extension CircularProgressBar: ProgressObject {}
