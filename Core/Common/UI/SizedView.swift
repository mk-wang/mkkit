//
//  SizedView.swift
//  MKKit
//
//  Created by MK on 2023/4/10.
//

import UIKit

// MARK: - SizedView

open class SizedView: UIView {
    private let sizeSubject = CurrentValueSubject<CGSize, Never>(.zero)
    open lazy var sizePublisher = sizeSubject.removeDuplicates().eraseToAnyPublisher()

    override open func layoutSubviews() {
        super.layoutSubviews()
        let rect = bounds
        if !rect.isEmpty, rect != .zero {
            sizeSubject.send(rect.size)
        }
    }
}
