//
//  IGTextItem.swift
//  MKKit
//
//  Created by MK on 2023/7/31.
//

import Foundation
import IGListKit
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

    override open func diffIdentifier() -> NSObjectProtocol {
        text as NSString
    }

    override open func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        text == (object as? Self)?.text
    }
}

public extension IGTextItem {
    static func igController<Item: IGTextItem, Cell: IGTextItemCell>(
        item: Item.Type = IGTextItem.self,
        cell: Cell.Type = IGTextItemCell.self,
        minHeight: CGFloat? = nil,
        configureBlock: ((Item, Cell) -> Void)? = nil,
        clickBlock: VoidFunction1<Int>? = nil
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
        ctr.onClick = clickBlock
        return ctr
    }
}

// MARK: - IGTextItemCell

open class IGTextItemCell: HighlightCollectionViewCell {
    open var item: IGTextItem? {
        didSet {
            update(by: item)
        }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    open var textlbl: UILabel?

    override open func layoutSubviews() {
        super.layoutSubviews()

        if let item, contentView.isReadyToConfig {
            readyToLayout(item: item)
        }
    }

    open func readyToLayout(item: IGTextItem) {
        let lbl = makeLbl(item: item)
        contentView.addSnpSubview(lbl)
        textlbl = lbl
    }

    open func makeLbl(item: IGTextItem) -> UILabel {
        let lbl = UILabel(text: item.text, style: item.textStyle)
        lbl.addSnpConfig { _, make in
            make.edges.equalToSuperview()
        }
        return lbl
    }

    open func update(by item: IGTextItem?) {
        textlbl?.text = item?.text
        if let style = item?.textStyle {
            textlbl?.applyTextStyle(style: style)
        }
    }

    public static func heightFor(item: IGTextItem, width: CGFloat) -> CGFloat {
        item.text.textViewSize(font: item.textStyle.font, width: width).height.cgfCeil
    }
}
