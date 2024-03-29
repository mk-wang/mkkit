//
//  UIButtonExt.swift
//
//
//  Created by MK on 2021/7/8.
//

import UIKit

public extension UIButton {
    var imageTitleSpace: CGFloat {
        get {
            imageEdgeInsets.right
        }
        set {
            if Lang.current.isRTL {
                imageEdgeInsets = UIEdgeInsets(top: 0, left: newValue, bottom: 0, right: 0)
                titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: newValue)
            } else {
                imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: newValue)
                titleEdgeInsets = UIEdgeInsets(top: 0, left: newValue, bottom: 0, right: 0)
            }
        }
    }

    func rangeImageTitle(margin: CGFloat, pad: CGFloat) {
        let newValue = margin + pad
        if Lang.current.isRTL {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: newValue, bottom: 0, right: margin)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: newValue)
        } else {
            imageEdgeInsets = UIEdgeInsets(top: 0, left: margin, bottom: 0, right: newValue)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: newValue, bottom: 0, right: margin)
        }
    }

    func rangeTitle(_ margin: CGFloat) {
        titleEdgeInsets = .horizontal(margin)
    }

    func setContentToFill() {
        contentHorizontalAlignment = .fill
        contentVerticalAlignment = .fill
    }

    var adjustsFontSizeToFitWidth: Bool {
        get {
            titleLabel?.adjustsFontSizeToFitWidth ?? false
        }
        set {
            titleLabel?.adjustsFontSizeToFitWidth = newValue
        }
    }
}

public extension UIButton {
    func alignVerticalCenter(padding: CGFloat = 1.0) {
        guard let imageSize = imageView?.bounds.size,
              let titleSize = titleLabel?.bounds.size
        else {
            return
        }

        let totalHeight = imageSize.height + titleSize.height + padding
        let imageOffset = (titleSize.width) / 2

        imageEdgeInsets = UIEdgeInsets(top: imageSize.height - totalHeight,
                                       left: imageOffset,
                                       bottom: 0,
                                       right: -imageOffset).langFlip

        titleEdgeInsets = UIEdgeInsets(top: 0,
                                       left: -imageSize.width,
                                       bottom: -(totalHeight - titleSize.height),
                                       right: 0).langFlip
    }
}
