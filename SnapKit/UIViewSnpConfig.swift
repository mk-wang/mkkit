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

    func addSnapSubview(_ guide: UILayoutGuide) {
        addLayoutGuide(guide)
        guide.applySnpConfig()
    }

    func applySnpConfig() {
        if let config = snpConfig {
            snp.makeConstraints {
                config(self.superview!, $0)
            }
        }
    }
}

public extension UIView {
    func addSnapScrollView(vertical: Bool, configure: (UIView) -> Void) {
        let scrollView = UIScrollView()
        scrollView.snpConfig = { _, make in
            make.edges.equalToSuperview()
        }
        addSnapSubview(scrollView)

        let contentView = UIView()
        contentView.snpConfig = { _, make in
            if vertical {
                make.top.bottom.equalToSuperview()
                make.left.right.equalTo(scrollView.superview!)
            } else {
                make.left.right.equalToSuperview()
                make.top.bottom.equalTo(scrollView.superview!)
            }
        }
        scrollView.addSnapSubview(contentView)
        configure(contentView)
    }
}

public extension UILayoutGuide {
    var snpConfig: SnapKitMaker? {
        get {
            getAssociatedObject(&AssociatedKeys.kSnapConfig) as? SnapKitMaker
        }
        set {
            setAssociatedObject(&AssociatedKeys.kSnapConfig, newValue)
        }
    }

    func applySnpConfig() {
        if let config = snpConfig {
            snp.makeConstraints {
                config(self.owningView!, $0)
            }
        }
    }
}

// MARK: - AssociatedKeys

private enum AssociatedKeys {
    static var kSnapConfig = 0
}
