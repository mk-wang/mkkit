//
//  MKListView.swift
//
//  Created by MK on 2021/5/31.
//

import OpenCombine
import UIKit

// MARK: - PageView

public protocol PageView: AnyObject {
    var pageCount: Int {
        get
    }

    var currentPage: Int {
        get
    }

    func toPage(index _: Int, animated _: Bool)
}

// MARK: - PageViewIndexChangeEvent

public enum PageViewIndexChangeEvent {
    case toPage
    case scroll
}

// MARK: - PageViewIndexScrollBehavior

public enum PageViewIndexScrollBehavior {
    case end
    case scrolling
}

// MARK: - MKListView

open class MKListView: UIView {
    public struct Config {
        let spacing: CGFloat
        let initialIndex: Int
        let width: CGFloat?
        let builder: (UIView, Int) -> UIView?
        let count: Int

        public init(count: Int,
                    spacing: CGFloat = 0,
                    initialIndex: Int = 0,
                    width: CGFloat? = nil,
                    builder: @escaping (UIView, Int) -> UIView?)
        {
            self.initialIndex = initialIndex
            self.spacing = spacing
            self.width = width
            self.count = count
            self.builder = builder
        }
    }

    public let config: Config

    public var pageCount: Int {
        config.count
    }

    public var scrollConfigure: ((UIScrollView) -> Void)?
    public var onOffsetChange: ((UIScrollView) -> Void)?
    public var onScrollEnd: ((UIScrollView) -> Void)?
    public var onIndexChange: ((Int, Int, PageViewIndexChangeEvent) -> Void)? // old , current, event

    private var toPaging = false

    public var indexChangeBehavior: PageViewIndexScrollBehavior = .end

    public private(set) lazy var currentPage = config.initialIndex

    public init(frame: CGRect, config: Config) {
        self.config = config
        super.init(frame: frame)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate(set) var scrollView: UIScrollView?

    fileprivate var extendHitInset: UIEdgeInsets?

    private var viewList = [UIView]()

    public var isScrollEnabled: Bool {
        get {
            scrollView?.isScrollEnabled ?? false
        }
        set {
            scrollView?.isScrollEnabled = newValue
        }
    }

    func setIndex(index: Int, event: PageViewIndexChangeEvent) {
        guard index != currentPage else {
            return
        }
        let old = currentPage
        currentPage = index
        onIndexChange?(old, currentPage, event)
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        guard isReadyToConfig, pageCount > 0 else {
            return
        }

        weak var weakSelf = self
        addSnpScrollView(vertical: false) { scroll, box in
            weakSelf?.scrollView = scroll
            weakSelf?.setupBox(scroll: scroll, box: box)
        }

        layoutIfNeeded()
        toPage(index: currentPage, animated: false)
    }

    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rt = super.hitTest(point, with: event)
        guard rt == nil, let extendHitInset else {
            return rt
        }

        let rect = bounds.inset(by: extendHitInset)
        return rect.contains(point) ? scrollView : nil
    }
}

extension MKListView {
    open func setupBox(scroll: UIScrollView, box: UIView) {
        scrollView = scroll

        scroll.delegate = self
        scroll.showsHorizontalScrollIndicator = false

        scrollConfigure?(scroll)

        var builders: [UIView.SnpStackViewBuilder] = []

        for index in 0 ..< pageCount {
            if index != 0 {
                builders.append(.space(config.spacing))
            }

            let cell = config.builder(self, index) ?? .init()
            let cellWidth = config.width ?? bounds.size.width
            cell.addSnpConfig { _, make in
                make.verticalEdges.equalToSuperview()
                make.width.equalTo(cellWidth)
            }
            viewList.append(cell)
            builders.append(.view(cell))
        }
        box.addSnpStackSubviews(.horizontal, builders: builders)
    }

    open func contentAt(index: Int) -> UIView? {
        viewList.at(index)
    }
}

// MARK: PageView

extension MKListView: PageView {}

// MARK: UIScrollViewDelegate

extension MKListView: UIScrollViewDelegate {
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        onOffsetChange?(scrollView)
        if !toPaging, indexChangeBehavior == .scrolling {
            updateIndexByScroller(scrollView)
        }
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let scrollToScrollStop = !scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
        if scrollToScrollStop {
            scrollDidEnd(scrollView)
        }
    }

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let dragToDragStop = scrollView.isTracking && !scrollView.isDragging && !scrollView.isDecelerating
            if dragToDragStop {
                scrollDidEnd(scrollView)
            }
        }
    }

    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollDidEnd(scrollView)
    }

    @objc func scrollDidEnd(_ scrollView: UIScrollView) {
        onScrollEnd?(scrollView)

        if indexChangeBehavior == .end {
            updateIndexByScroller(scrollView)
        }
    }

    @objc func updateIndexByScroller(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x
        let cellWidth = config.width ?? bounds.size.width
        var page = Int(round(offset / (config.spacing + cellWidth)))
        if Lang.current.isRTL {
            page = config.count - 1 - page
        }
        setIndex(index: page, event: .scroll)
    }
}

public extension MKListView {
    open func toPage(index: Int, animated: Bool) {
        guard let scrollView else {
            return
        }

        toPaging = true
        let postion = position(index: index, scrollView: scrollView)
        let offset: CGPoint = .init(x: postion, y: 0)

        weak var weakSelf = self
        scrollView.setContentOffset(offset, duration: animated ? 0.25 : nil) { _ in
            weakSelf?.toPaging = false
        }

        setIndex(index: index, event: .toPage)
    }

    private func position(index: Int, scrollView: UIScrollView) -> CGFloat {
        let fixedIndex: CGFloat = .init(Lang.current.isRTL ? (config.count - 1 - index) : index)
        let cellWidth = config.width ?? bounds.size.width
        var x = (cellWidth + config.spacing) * fixedIndex
        let minX = scrollView.minOffset(vertical: false)

        if x < minX {
            x = minX
        } else {
            let maxX = scrollView.maxOffset(vertical: false)
            x = min(maxX, x)
        }

        return x
    }
}

// MARK: - MKPagedListView

open class MKPagedListView: UIView {
    public struct Config {
        let spacing: CGFloat
        let initialIndex: Int
        let width: CGFloat
        let builder: (UIView, Int) -> UIView?
        let count: Int
        let scaleFact: CGFloat?

        public init(count: Int,
                    spacing: CGFloat,
                    initialIndex: Int = 0,
                    width: CGFloat,
                    scaleFact: CGFloat? = nil,
                    builder: @escaping (UIView, Int) -> UIView?)
        {
            self.initialIndex = initialIndex
            self.spacing = spacing
            self.width = width
            self.count = count
            self.scaleFact = scaleFact
            self.builder = builder
        }
    }

    public let config: Config

    public var onIndexChange: ((Int, Int, PageViewIndexChangeEvent) -> Void)? // old , current, event
    public var onOffsetChange: ((UIScrollView) -> Void)?
    public var onScrollEnd: ((UIScrollView) -> Void)?

    public var indexChangeBehavior: PageViewIndexScrollBehavior {
        get {
            listView.indexChangeBehavior
        }
        set {
            listView.indexChangeBehavior = newValue
        }
    }

    public var cardCount: Int {
        config.count
    }

    public private(set) lazy var currentPage = config.initialIndex

    public init(frame: CGRect, config: Config) {
        self.config = config
        super.init(frame: frame)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate var pages = [UIView]()

    public var isScrollEnabled: Bool {
        get {
            listView.isScrollEnabled
        }
        set {
            listView.isScrollEnabled = newValue
        }
    }

    private lazy var listView: MKListView = {
        let selfSize = self.bounds.size
        let cellWidth = config.width
        let spacing = config.spacing
        let listWidth = spacing + cellWidth

        let listSize: CGSize = .init(listWidth, selfSize.height)
        let builder = config.builder

        weak var weakSelf = self
        let needScale = config.scaleFact != nil
        var listConfig: MKListView.Config = .init(count: config.count,
                                                  spacing: 0,
                                                  initialIndex: config.initialIndex,
                                                  width: listWidth,
                                                  builder: { _, index in
                                                      let box = UIView()
                                                      let view = builder(box, index) ?? .init()
                                                      view.addSnpEdgesToSuper(.only(end: spacing))
                                                      box.addSnpSubview(view)
                                                      weakSelf?.pages.append(view)
                                                      return box
                                                  })

        let box = MKListView(frame: listSize.toRect(), config: listConfig)
        let xMargin = (selfSize.width - cellWidth) / 2
        box.addSnpConfig { _, make in
            make.size.equalTo(listSize)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(xMargin)
        }
        box.scrollConfigure = {
            $0.clipsToBounds = false
            $0.isPagingEnabled = true
        }
        box.extendHitInset = .only(start: -xMargin, end: min(0, xMargin + listWidth - selfSize.width))
        box.clipsToBounds = false

        box.onOffsetChange = {
            weakSelf?.offsetChange($0)
        }

        box.onIndexChange = {
            weakSelf?.onIndexChange?($0, $1, $2)
        }

        box.onScrollEnd = {
            weakSelf?.onScrollEnd?($0)
        }
        return box
    }()

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard isReadyToConfig, cardCount > 0 else {
            return
        }
        addSnpSubview(listView)
    }

    open func toPage(index: Int, animated: Bool) {
        listView.toPage(index: index, animated: animated)
    }

    open func offsetChange(_ scrollView: UIScrollView) {
        defer {
            onOffsetChange?(scrollView)
        }
        guard let fact = config.scaleFact else {
            return
        }
        let selfSize = bounds.size
        let offset = scrollView.contentOffset.x
        let position = offset + (selfSize.height / 2) + (config.spacing) / 2
        for view in pages {
            let centerX = view.superview!.center.x
            let distance = abs(position - centerX)
            if distance < selfSize.width {
                let scale: CGFloat = 1 / (1 + fact * distance)
                view.transform = .init(scaleX: scale, y: scale)
            }
        }
    }

    open func pageAt(index: Int) -> UIView? {
        pages.at(index)
    }
}

// MARK: PageView

extension MKPagedListView: PageView {
    public var pageCount: Int {
        config.count
    }
}
