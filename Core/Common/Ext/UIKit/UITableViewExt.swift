//
//  UITableViewExt.swift
//
//
//  Created by MK on 2022/7/21.
//

import UIKit

public extension UITableView {
    func reloadWithoutAnimation() {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        reloadData()
        CATransaction.commit()
    }

    func reloadDataWithCompletion(_ completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        reloadData()
        CATransaction.commit()
    }
}

public extension UITableViewCell {
    func setSelectColor(_ color: UIColor?) {
        guard let color else {
            selectedBackgroundView = nil
            return
        }
        let bgColorView = UIView()
        bgColorView.backgroundColor = color
        selectedBackgroundView = bgColorView
    }
}
