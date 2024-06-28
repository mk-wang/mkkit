//
//  ProgressBar.swift
//  MKKit
//
//  Created by MK on 2024/6/28.
//

import Foundation
import UIKit

open class ProgressBar: MKBaseView {
    private let progressLayer = CALayer()

    open var rtl: Bool = true

    open var progress: Float = 0.0 {
        didSet {
            progress = min(max(progress, 0.0), 1.0)
            updateProgress()
        }
    }

    open func setProgress(_ value: Float, animated: Bool) {
        if animated {
            progress = value
        } else {
            UIView.runDisableActions { [weak self] in
                self?.progressLayer.removeAllAnimations()
                self?.progress = value
            }
        }
    }

    open var progressBarColor: UIColor = .blue {
        didSet {
            progressLayer.backgroundColor = progressBarColor.cgColor
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        guard !isEmptyBounds, progressLayer.superlayer == nil else {
            return
        }

        UIView.runDisableActions { [weak self] in
            guard let self else {
                return
            }
            progressLayer.backgroundColor = progressBarColor.cgColor
            layer.addSublayer(progressLayer)
            updateProgress()
        }
    }

    open func updateProgress() {
        let selfSize = bounds.size
        let size: CGSize = .init(width: selfSize.width * CGFloat(progress),
                                 height: selfSize.height)
        var point: CGPoint = .zero
        if rtl, Lang.current.isRTL {
            point.x = selfSize.width - size.width
        }
        progressLayer.frame = .init(origin: point, size: size)
    }
}
