//
//  UITableViewExt.swift
//
//
//  Created by MK on 2022/7/21.
//

import UIKit

public extension UITableView {
    func reloadWithoutAnimation() {
        UIView.runDisableActions { [weak self] in
            self?.reloadData()
        }
    }

    func reloadDataWithCompletion(_ completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                if let cb = completion {
                    cb()
                }
                return
            }

            UIView.runDisableActions({ [weak self] in
                self?.reloadData()
            }, completion: completion)
        }
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
