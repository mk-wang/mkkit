//
//  UIViewSnp.swift
//
//
//  Created by MK on 2022/5/11.
//

import SnapKit
import UIKit

public extension UIView {
    enum SnpStackDirection {
        case vertical
        case horizontal
        case ltrHorizontal
    }

    enum SnpStackViewBuilder {
        case space(CGFloat)
        case view(UIView?)
        case builder((UIView, UIView?) -> UIView?)
    }

    func addSnpStackSubviews(_ direction: SnpStackDirection,
                             buidlers: [SnpStackViewBuilder])
    {
        var last: UIView?
        for builder in buidlers {
            var subview: UIView?

            switch builder {
            case let .space(size):
                subview = UIView()
                subview?.addSnpConfig { _, make in
                    if direction == .vertical {
                        make.width.equalTo(0)
                        make.centerX.equalToSuperview()
                        make.height.equalTo(size)
                    } else {
                        make.height.equalTo(0)
                        make.centerY.equalToSuperview()
                        make.width.equalTo(size)
                    }
                }
            case let .view(aView):
                subview = aView
            case let .builder(cb):
                subview = cb(self, last)
            }

            if let subview {
                subview.addSnpConfig { _, make in
                    if direction == .vertical {
                        if let last {
                            make.top.equalTo(last.snp.bottom)
                        } else {
                            make.top.equalToSuperview()
                        }
                    } else if direction == .horizontal {
                        if let last {
                            make.leading.equalTo(last.snp.trailing)
                        } else {
                            make.leading.equalToSuperview()
                        }
                    } else {
                        if let last {
                            make.left.equalTo(last.snp.right)
                        } else {
                            make.left.equalToSuperview()
                        }
                    }
                }
                addSnpSubview(subview)
                last = subview
            }
        }
        last?.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
        }
    }
}
