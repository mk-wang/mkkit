//
//  SectionGroupViewFlowLayout.swift
//  MKKit
//
//  Created by MK on 2023/8/29.
//

import UIKit

// MARK: - SectionGroupViewFlowLayout

open class SectionGroupViewFlowLayout: UICollectionViewFlowLayout {
    open var config: Config? = nil

    private var decorationRegistered: Bool = false

    override open func prepare() {
        super.prepare()

        if !decorationRegistered {
            register(ReusableView.self, forDecorationViewOfKind: Self.decorationViewKind)
            decorationRegistered = true
        }
    }

    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect)

        guard let config, var attributes, let collectionView else {
            return attributes
        }

        for section in 0 ..< collectionView.numberOfSections {
            guard config.shouldGroup(section) else {
                continue
            }
            let attrs = LayoutAttributes(forDecorationViewOfKind: Self.decorationViewKind,
                                         with: .init(row: 0, section: section))

            var rect = collectionView.frame(of: section)

            if let inset = config.viewEdgeInsets?(section) {
                rect = rect.inset(by: inset)
            }

            attrs.frame = rect
            attrs.zIndex = -1
            attrs.configure = config.viewConfigure

            attributes.append(attrs)
        }

        return attributes
    }
}

extension SectionGroupViewFlowLayout {
    private static let decorationViewKind = "sectionGroupView"

    public struct Config {
        let shouldGroup: (Int) -> Bool
        let viewConfigure: (Int, UIView) -> Void
        let viewEdgeInsets: ((Int) -> UIEdgeInsets?)?

        public init(shouldGroup: @escaping (Int) -> Bool,
                    viewConfigure: @escaping (Int, UIView) -> Void,
                    viewEdgeInsets: ((Int) -> UIEdgeInsets?)? = nil)
        {
            self.shouldGroup = shouldGroup
            self.viewConfigure = viewConfigure
            self.viewEdgeInsets = viewEdgeInsets
        }
    }
}

// MARK: - LayoutAttributes

private class LayoutAttributes: UICollectionViewLayoutAttributes {
    var configure: ((Int, UIView) -> Void)?

    override func copy(with zone: NSZone? = nil) -> Any {
        let attrs = super.copy(with: zone)
        if let attrs = attrs as? Self {
            attrs.configure = configure
        }
        return attrs
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
