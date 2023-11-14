//
//  SectionBackgroundFlowLayout.swift
//  MKKit
//
//  Created by MK on 2023/8/29.
//

import UIKit

// MARK: - SectionBackgroundFlowLayout

open class SectionBackgroundFlowLayout: UICollectionViewFlowLayout {
    // MARK: prepareLayout

    private static let decorationViewKind = "sectionBackgroundView"

    open var backgroundConfigure: ((Int, UIView) -> Void)?
    open var backgroundInset: UIEdgeInsets?

    override open func prepare() {
        super.prepare()

        register(ReusableView.self, forDecorationViewOfKind: Self.decorationViewKind)
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect)

        guard let backgroundConfigure, var attributes, let collectionView else {
            return attributes
        }

        for section in 0 ..< collectionView.numberOfSections {
            let attrs = LayoutAttributes(forDecorationViewOfKind: Self.decorationViewKind,
                                         with: .init(row: 0, section: section))

            var rect = collectionView.frame(of: section)

            if let backgroundInset {
                rect = rect.inset(by: backgroundInset)
            }

            attrs.frame = rect
            attrs.zIndex = -1
            attrs.configure = backgroundConfigure

            attributes.append(attrs)
        }

        return attributes
    }
}

// MARK: - LayoutAttributes

private class LayoutAttributes: UICollectionViewLayoutAttributes {
    var configure: ((Int, UIView) -> Void)?

    override func copy(with zone: NSZone? = nil) -> Any {
        let newAttributes: LayoutAttributes = super.copy(with: zone) as! LayoutAttributes
        newAttributes.configure = configure
        return newAttributes
    }
}

// MARK: - ReusableView

private class ReusableView: UICollectionReusableView {
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard let configure = (layoutAttributes as? LayoutAttributes)?.configure else {
            return
        }

        configure(layoutAttributes.indexPath.section, self)
    }
}
