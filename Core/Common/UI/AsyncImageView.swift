//
//  AsyncImageView.swift
//  MKKit
//
//  Created by MK on 2023/3/27.
//

import Foundation
import OpenCombine

open class AsyncImageView: UIImageView {
    private var imageCancellable: AnyCancellable?

    public var placeHolder: UIImage? = nil

    public var publisher: AnyPublisher<UIImage?, Never>? {
        didSet {
            image = placeHolder
            guard let publisher else {
                imageCancellable = nil
                return
            }
            imageCancellable = publisher.sink { [weak self] in
                self?.image = $0 ?? self?.placeHolder
            }
        }
    }
}
