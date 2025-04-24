//
//  MKBaseCellView.swift
//  MKKit
//
//  Created by MK on 2023/7/21.
//

import Foundation
import UIKit

// MARK: - MKBaseCellView

open class MKBaseCellView: UICollectionViewCell {
    open var readyToLayoutBlock: VoidFunction?
    open var isReady: Bool = false

    open var extendHitInset: UIEdgeInsets?

    override public init(frame: CGRect) {
        super.init(frame: frame)
        doInit()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if contentView.isReadyToConfig {
            isReady = true
            readyToLayout()
            readyToLayoutBlock?()
        }
    }
}

extension MKBaseCellView {
    @objc open func doInit() {}

    @objc open func readyToLayout() {}
}

// MARK: - HighlightCollectionViewCell

open class HighlightCollectionViewCell: MKBaseCellView {
    override open var isHighlighted: Bool {
        didSet {
            handleHighlightState(highLighted: isHighlighted)
        }
    }
}

// MARK: - OverlayCollectionViewCell

open class OverlayCollectionViewCell: HighlightCollectionViewCell {
    public var overlayColor: UIColor = .black.withAlphaComponent(0.08) {
        didSet {
            cleanHighlightHandler()
            addHighlightHandler(OverlayViewHighlightHandler(overlayColor))
        }
    }

    override open func doInit() {
        super.doInit()
        addHighlightHandler(OverlayViewHighlightHandler(overlayColor))
    }
}

// MARK: - ScaleCollectionViewCell

open class ScaleCollectionViewCell: HighlightCollectionViewCell {
    override open func doInit() {
        super.doInit()
        addHighlightHandler(ScaleViewHighlightHandler())
    }
}
