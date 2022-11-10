//
//  TouchExtUView.swift
//
//
//  Created by MK on 2022/10/26.
//

import Foundation

// MARK: - FileListView

open class TouchExtUView: UIView {
    var tapExt = CGSize.zero
    override open func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        bounds.insetBy(dx: -tapExt.width, dy: -tapExt.height).contains(point)
    }
}
