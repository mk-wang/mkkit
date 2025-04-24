//
//  MKGridView.swift
//
//  Created by MK on 2023/10/11.
//

import Foundation
import UIKit

// MARK: - MKGridView

open class MKGridView: MKBaseView {
    public let config: GridConfig

    public var layoutBuilder: (() -> UICollectionViewLayout)?
    public var flowLayoutBuilder: (() -> UICollectionViewFlowLayout)?
    public var onItemClick: ((Int) -> Void)?

    public let listConfig: VoidFunction1<UICollectionView>?

    private lazy var listView: UICollectionView = {
        let selfBounds = self.bounds

        let layout: UICollectionViewLayout = (layoutBuilder?() ?? flowLayoutBuilder?()) ?? { [unowned(unsafe) self] in
            let layout = UICollectionViewFlowLayout()
            let isVertical = config.itemPerLine > 1
            if let flow = layout as? UICollectionViewFlowLayout {
                flow.scrollDirection = isVertical ? .vertical : .horizontal
                if isVertical {
                    let itemSpacing = config.itemSpacing(for: selfBounds.size.width)
                    flow.minimumInteritemSpacing = itemSpacing
                    flow.minimumLineSpacing = config.lineSpacing
                } else {
                    flow.minimumInteritemSpacing = 0
                    flow.minimumLineSpacing = config.lineSpacing
                }
                flow.itemSize = config.itemSize
                flow.sectionInset = config.inset
            }
            return layout
        }()

        let view = UICollectionView(frame: selfBounds, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.delaysContentTouches = false

        view.addSnpEdgesToSuper()

        view.register(config.cellType, forCellWithReuseIdentifier: Cell.idf)
        view.delegate = self

        return view
    }()

    public init(frame: CGRect, config: GridConfig, listConfig: VoidFunction1<UICollectionView>? = nil) {
        self.config = config
        self.listConfig = listConfig
        super.init(frame: frame)
    }

    override open func readyToLayout() {
        super.readyToLayout()

        addSnpSubview(listView)

        listView.dataSource = self
        listConfig?(listView)
    }

    public func reloadData() {
        guard listView.superview != nil else {
            return
        }

        listView.reloadData()
    }
}

// MARK: UICollectionViewDataSource

extension MKGridView: UICollectionViewDataSource {
    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        config.itemCount
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.idf, for: indexPath)

        if let gridCell = cell as? Cell {
            let index = indexPath.row
            gridCell.setup(index: index, config: config.cellConfig)
        }

        return cell
    }
}

// MARK: UICollectionViewDelegate

extension MKGridView: UICollectionViewDelegate {
    public func collectionView(_: UICollectionView,
                               didSelectItemAt indexPath: IndexPath)
    {
        onItemClick?(indexPath.row)
    }
}

// MARK: MKGridView.GridConfig

public extension MKGridView {
    struct GridConfig {
        let itemCount: Int
        let itemSize: CGSize
        let itemPerLine: Int
        let lineSpacing: CGFloat
        let inset: UIEdgeInsets
        let cellConfig: CellConfig
        let cellType: Cell.Type

        public init(itemCount: Int,
                    itemSize: CGSize,
                    itemPerLine: Int,
                    lineSpacing: CGFloat,
                    cellConfig: CellConfig,
                    inset: UIEdgeInsets = .zero,
                    cellType: Cell.Type = Cell.self)
        {
            self.itemCount = itemCount
            self.itemSize = itemSize
            self.itemPerLine = itemPerLine
            self.lineSpacing = lineSpacing
            self.cellConfig = cellConfig
            self.inset = inset
            self.cellType = cellType
        }
    }

    struct CellConfig {
        let builder: (Int, CGRect) -> UIView?
        let resuse: ((Int, UIView) -> Void)?

        public init(builder: @escaping (Int, CGRect) -> UIView?,
                    resuse: ((Int, UIView) -> Void)? = nil)
        {
            self.builder = builder
            self.resuse = resuse
        }
    }
}

public extension MKGridView.GridConfig {
    var estimatedHeight: CGFloat {
        var height = inset.verticalSize
        let lineCount = Int((itemCount + itemPerLine - 1) / itemPerLine)

        if lineCount > 0 {
            height += CGFloat(lineCount) * (lineSpacing + itemSize.height) - lineSpacing
        }

        return ceil(height)
    }

    func itemSpacing(for width: CGFloat) -> CGFloat {
        let count = CGFloat(itemPerLine)
        return floor((width - inset.horizontalSize - count * itemSize.width) / (count - 1))
    }
}

// MARK: - MKGridView.Cell

extension MKGridView {
    open class Cell: UICollectionViewCell {
        static let idf = "idf"
        var index: Int?
        var config: CellConfig?

        weak var reuseView: UIView?

        func setup(index: Int, config: CellConfig) {
            self.index = index
            self.config = config

            if let reuseView, let resuse = config.resuse {
                resuse(index, reuseView)
            }
        }

        override open func layoutSubviews() {
            super.layoutSubviews()

            guard let index, let config, contentView.isReadyToConfig,
                  let view = config.builder(index, contentView.bounds)
            else {
                return
            }

            view.addSnpEdgesToSuper()
            contentView.addSnpSubview(view)
            reuseView = view
        }
    }
}
