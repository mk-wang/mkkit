//
//  UIImageViewExt.swift
//
//
//  Created by MK on 2022/3/28.
//

import UIKit

public extension UIImageView {
    func setImage(image: UIImage?, tintColor: UIColor) {
        self.image = image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = tintColor
    }

    func animation(images: [UIImage],
                   duration: TimeInterval,
                   repeatCount: Int = 0,
                   tintColor: UIColor? = nil)
    {
        animationImages = tintColor == nil ? images : images.map {
            $0.withRenderingMode(.alwaysTemplate)
        }
        self.tintColor = tintColor
        animationDuration = duration
        animationRepeatCount = repeatCount
    }
}
