//
//  UIViewSnp.swift
//
//
//  Created by MK on 2022/5/11.
//

import SnapKit
import UIKit

extension UIView {
    enum SnpViewBuilder {
        case view(UIView?, SnapKitMaker? = nil)
        case builder((UIView?) -> UIView?)
    }

    func addSnapSubviews(_ builders: [SnpViewBuilder]) {
        builders.forEach { builder in
            var view: UIView?
            switch builder {
            case let .view(subView, config):
                view = subView
                view?.snpConfig = config
            case let .builder(viewBuilder):
                view = viewBuilder(self)
            }

            if let view {
                self.addSnapSubview(view)
            }
        }
    }

    convenience init(snpBuilders: [SnpViewBuilder],
                     snpConfig: SnapKitMaker? = nil)
    {
        self.init()

        self.snpConfig = snpConfig

        addSnapSubviews(snpBuilders)
    }
}
