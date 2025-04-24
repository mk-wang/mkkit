//
//  CarouselView.swift
//  FaceYoga
//
//  Created by MK on 2024/9/26.
//

import UIKit

// MARK: - LoopView

open class CarouselView: MKBaseView {
    public struct Config {
        let overlap: CGFloat
        let displayCount: Int
        let animateInterval: TimeInterval
        let moveDuration: TimeInterval
        let moveDelay: TimeInterval
        let itemSize: CGSize
        let itemBuilders: [ValueBuilder<UIView>]

        public init(overlap: CGFloat,
                    displayCount: Int = 3,
                    animateInterval: TimeInterval = 4,
                    moveDuration: TimeInterval = 0.5,
                    moveDelay: TimeInterval = 0.1,
                    itemSize: CGSize,
                    itemBuilders: [ValueBuilder<UIView>])
        {
            self.overlap = overlap
            self.displayCount = displayCount
            self.animateInterval = animateInterval
            self.moveDuration = moveDuration
            self.moveDelay = moveDelay
            self.itemSize = itemSize
            self.itemBuilders = itemBuilders
        }

        public var totalSize: CGSize {
            guard displayCount > 1 else {
                return itemSize
            }
            let width = (itemSize.width - overlap) * CGFloat(displayCount) + overlap
            return .init(width: width, height: itemSize.height)
        }
    }

    public let config: Config
    private let rects: [CGRect]

    private var viewCache: [UIView?]?

    public init(config: Config, cacheView: Bool = true) {
        self.config = config
        do {
            var rect = config.itemSize.toRect()
            var rects: [CGRect] = .init(repeating: rect, count: config.displayCount)
            let count = config.displayCount
            for index in 1 ..< count {
                rect.origin.x += config.itemSize.width - config.overlap
                rects[count - 1 - index] = rect
            }
            self.rects = rects
        }
        viewCache = cacheView ? .init(repeating: nil, count: config.itemBuilders.count) : nil
        super.init(frame: config.totalSize.toRect())
    }

    override public var intrinsicContentSize: CGSize { config.totalSize }

    private var nextIndex: Int = 0 {
        didSet {
            if nextIndex >= config.itemBuilders.count {
                nextIndex = 0
            }
        }
    }

    private var timer: SwiftTimer?

    override public func readyToLayout() {
        super.readyToLayout()
        clipsToBounds = true

        let limit = min(config.displayCount, config.itemBuilders.count)

        for index in 0 ..< limit {
            let view = viewOfIndex(index)
            view.frame = rectOfIndex(index)
            addSubview(view)
        }
        nextIndex = config.displayCount
        nextRun(interval: config.animateInterval * 0.5)
    }

    var canAnimate: Bool {
        config.itemBuilders.count > config.displayCount
    }

    public func startAnimation() {
        guard canAnimate else {
            return
        }

        if let outView = subviews.first {
            let moveDuration = config.moveDuration
            UIView.animate(withDuration: moveDuration, animations: {
                outView.transform = outView.transform.scaledBy(x: 0.1, y: 0.1)
                outView.alpha = 0
            }) { [weak self] _ in
                DispatchQueue.mainAsync(after: 0.005) {
                    self?.onOutViewScaled(outView: outView)
                }
            }
        }
    }

    public func stopAnimation() {
        timer = nil
    }

    private func onOutViewScaled(outView: UIView) {
        outView.removeFromSuperview()
        outView.transform = .identity
        outView.alpha = 1

        addNext()

        let moveDuration = config.moveDuration
        let moveDelay = config.moveDelay
        let list = subviews
        let listCount = list.count
        guard listCount > 0 else {
            return
        }

        var doneCount = 0
        for (index, subView) in list.enumerated() {
            UIView.animate(withDuration: moveDuration, delay: moveDelay * Double(index), options: [], animations: { [weak self] in
                guard let self else {
                    return
                }
                subView.frame = rectOfIndex(index)
            }) { [weak self] _ in
                doneCount += 1
                if doneCount == listCount {
                    DispatchQueue.mainAsync(after: 0.005) {
                        self?.nextRun()
                    }
                }
            }
        }
    }

    private func nextRun(interval: TimeInterval? = nil) {
        timer = .init(interval: interval ?? config.animateInterval,
                      handler: { [weak self] _ in
                          self?.startAnimation()
                      })
        timer?.start()
    }

    private func addNext() {
        let inView = viewOfIndex(nextIndex)
        inView.frame = .init(origin: .init(-config.itemSize.width, 0), size: config.itemSize)
        addSubview(inView)
        nextIndex += 1
        if nextIndex >= config.itemBuilders.count {
            nextIndex = 0
        }
    }

    private func rectOfIndex(_ index: Int) -> CGRect {
        rects[index]
    }

    private func viewOfIndex(_ index: Int) -> UIView {
        if let value = viewCache?[index] {
            return value
        }
        let view = config.itemBuilders[index]()
        viewCache?[index] = view
        return view
    }
}
