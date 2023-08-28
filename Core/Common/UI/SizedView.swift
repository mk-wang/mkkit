//
//  SizedView.swift
//  MKKit
//
//  Created by MK on 2023/4/10.
//

import Foundation
import OpenCombine

// MARK: - SizedContentView

open class SizedView: UIView {
    private let sizeSubject = CurrentValueSubject<CGSize, Never>(.zero)
    open lazy var sizePublisher = sizeSubject.removeDuplicates().eraseToAnyPublisher()

    override open func layoutSubviews() {
        super.layoutSubviews()
        if !bounds.isEmpty {
            sizeSubject.send(bounds.size)
        }
    }
}
