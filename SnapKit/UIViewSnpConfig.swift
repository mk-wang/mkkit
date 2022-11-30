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
    func addSnpSubview(_ view: UIView) {
        addSubview(view)
        view.applySnpConfig()
    }

    func addSnpSubview(_ guide: UILayoutGuide) {
        addLayoutGuide(guide)
        guide.applySnpConfig()
    }

    func addSnpConfig(_ config: @escaping SnapKitMaker) {
        var list = getAssociatedObject(&AssociatedKeys.kSnapConfig) as? NSMutableArray
        if list == nil {
            list = NSMutableArray()
            setAssociatedObject(&AssociatedKeys.kSnapConfig, list)
        }
        list?.add(config)
    }

    private func applySnpConfig() {
        guard let list = getAssociatedObject(&AssociatedKeys.kSnapConfig) as? NSMutableArray else {
            return
        }
        for item in list {
            if let config = item as? SnapKitMaker {
                snp.makeConstraints {
                    config(self.superview!, $0)
                }
            }
        }
    }
}

public extension UIView {
    @discardableResult
    func addSnpScrollView(vertical: Bool, configure: (UIView) -> Void) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.addSnpConfig { _, make in
            make.edges.equalToSuperview()
        }
        addSnpSubview(scrollView)

        let contentView = UIView()
        contentView.addSnpConfig { _, make in
            if vertical {
                make.top.bottom.equalToSuperview()
                make.left.right.equalTo(scrollView.superview!)
            } else {
                make.left.right.equalToSuperview()
                make.top.bottom.equalTo(scrollView.superview!)
            }
        }
        scrollView.addSnpSubview(contentView)
        configure(contentView)
        return scrollView
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
