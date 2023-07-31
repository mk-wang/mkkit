//
//  IGTextItem.swift
//  MKKit
//
//  Created by MK on 2023/7/31.
//

import Foundation
import IGListKit
import MKKit
import UIKit

// MARK: - IGTextItem

open class IGTextItem: IGSectionItem {
    public let text: String
    public let textStyle: TextViewStyle

    public init(text: String, textStyle: TextViewStyle) {
        self.text = text
        self.textStyle = textStyle
        super.init()
    }
}

public extension IGTextItem {
    static func igController<Item: IGTextItem, Cell: IGTextItemCell>(
        item: Item.Type = IGTextItem.self,
        cell: Cell.Type = IGTextItemCell.self,
        minHeight: CGFloat? = nil,
        configureBlock: ((Item, Cell) -> Void)? = nil
    ) -> IGSectionItemController<Item, Cell> {
        let ctr = IGSectionItemController<Item, Cell>()
        ctr.heightBlock = { _, item, width in
            var height = IGTextItemCell.heightFor(item: item, width: width)
            if let minHeight, height < minHeight {
                height = minHeight
            }
            return height
        }
        ctr.configureBlock = { item, cell in
            cell.item = item
            configureBlock?(item, cell)
        }
        return ctr
    }
}

// MARK: - IGTextItemCell

open class IGTextItemCell: UICollectionViewCell {
    open var item: IGTextItem? {
        didSet {
            textlbl?.text = item?.text
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open var textlbl: UILabel?

    override open func layoutSubviews() {
        super.layoutSubviews()

        if let item, contentView.isReadyToConfig {
            readyToLayout(item: item)
        }
    }

    open func readyToLayout(item: IGTextItem) {
        let lbl = UILabel(text: item.text, style: item.textStyle)
        lbl.addSnpConfig { _, make in
            make.edges.equalToSuperview()
        }
        contentView.addSnpSubview(lbl)
        textlbl = lbl
    }

    public static func heightFor(item: IGTextItem, width: CGFloat) -> CGFloat {
        item.text.textViewSize(font: item.textStyle.font, width: width).height
    }
}
