//
//  UIViewSnpConfig.swift
//
//
//  Created by MK on 2022/3/26.
//

import SnapKit
import UIKit

public typealias SnapKitMaker = (UIView, SnapKit.ConstraintMaker) -> Void

public extension UIView {
    var snpConfig: SnapKitMaker? {
        get {
            getAssociatedObject(&AssociatedKeys.kSnapConfig) as? SnapKitMaker
        }
        set {
            setAssociatedObject(&AssociatedKeys.kSnapConfig, newValue)
        }
    }

    func addSnapSubview(_ view: UIView) {
        addSubview(view)
        view.applySnpConfig()
    }

    func applySnpConfig() {
        if let config = snpConfig {
            snp.makeConstraints {
                config(self.superview!, $0)
            }
        }
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kSnapConfig = 0
}
