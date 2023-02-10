//
//  UIViewSnp.swift
//
//
//  Created by MK on 2022/5/11.
//

import SnapKit
import UIKit

public extension UIView {
    convenience init(direction: SnpStackDirection,
                     buidlers: [SnpStackViewBuilder])
    {
        self.init(frame: .zero)
        addSnpStackSubviews(direction, buidlers: buidlers)
    }
}

public extension UIView {
    enum SnpStackDirection {
        case vertical
        case horizontal
        case ltrHorizontal
    }

    enum SnpStackViewBuilder {
        case space(CGFloat? = nil)
        case view(UIView?)
        case tight(UIView?)
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
                        if let size {
                            make.height.equalTo(size)
                        }
                    } else {
                        make.height.equalTo(0)
                        make.centerY.equalToSuperview()
                        if let size {
                            make.width.equalTo(size)
                        }
                    }
                }
            case let .view(aView):
                subview = aView
            case let .tight(aView):
                subview = aView
                subview?.compressionLayout(for: direction == .vertical ? .vertical : .horizontal)
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
            if direction == .vertical {
                make.bottom.equalToSuperview()
            } else if direction == .horizontal {
                make.trailing.equalToSuperview()
            } else {
                make.right.equalToSuperview()
            }
        }
    }
}
