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
        case space(CGFloat? = nil, flex: CGFloat = 1)
        case view(UIView?)
        case tight(UIView?)
        case builder((UIView, SnpLayoutObject?) -> UIView?)
    }

    func addSnpStackSubviews(_ direction: SnpStackDirection,
                             buidlers: [SnpStackViewBuilder])
    {
        weak var lastObject: SnpLayoutObject?
        var firstFlex: (SnpLayoutObject, CGFloat)?
        for builder in buidlers {
            var snpObject: SnpLayoutObject?

            switch builder {
            case let .space(size, flex):
                #if DEBUG // && targetEnvironment(simulator)
                    snpObject = UIView()
                #else
                    snpObject = UILayoutGuide()
                #endif
                snpObject?.addSnpConfig { _, make in
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

                    if size == nil, flex > 0 {
                        if let firstFlex {
                            let amount = flex / firstFlex.1
                            if direction == .vertical {
                                make.height.equalTo(firstFlex.0.snpDSL.height).multipliedBy(amount)
                            } else {
                                make.width.equalTo(firstFlex.0.snpDSL.width).multipliedBy(amount)
                            }
                        } else {
                            firstFlex = (snpObject!, flex)
                        }
                    }
                }
            case let .view(aView):
                snpObject = aView
            case let .tight(aView):
                aView?.compressionLayout(for: direction == .vertical ? .vertical : .horizontal)
                snpObject = aView
            case let .builder(cb):
                snpObject = cb(self, lastObject)
            }

            if let snpObject {
                snpObject.addSnpConfig { _, make in
                    if let snp = lastObject?.snpDSL {
                        switch direction {
                        case .vertical:
                            make.top.equalTo(snp.bottom)
                        case .horizontal:
                            make.leading.equalTo(snp.trailing)
                        case .ltrHorizontal:
                            make.left.equalTo(snp.right)
                        }
                    } else {
                        switch direction {
                        case .vertical:
                            make.top.equalToSuperview()
                        case .horizontal:
                            make.leading.equalToSuperview()
                        case .ltrHorizontal:
                            make.left.equalToSuperview()
                        }
                    }
                }
                addSnpObject(snpObject)
                lastObject = snpObject
            }
        }
        lastObject?.makeConstraints { make in
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

public extension UIView {
    @discardableResult
    func addSnpScrollView(vertical: Bool,
                          configure: (UIScrollView, UIView) -> Void,
                          scrollBuilder: (() -> UIScrollView)? = nil) -> UIScrollView
    {
        let scrollView = scrollBuilder?() ?? UIScrollView()
        scrollView.addSnpConfig { _, make in
            make.edges.equalToSuperview()
        }
        addSnpSubview(scrollView)

        let contentView = UIView()
        contentView.addSnpConfig { [unowned(unsafe) self] _, make in
            if vertical {
                make.top.bottom.equalToSuperview()
                make.left.right.equalTo(self)

            } else {
                make.left.right.equalToSuperview()
                make.top.bottom.equalTo(self)
            }
        }
        scrollView.addSnpSubview(contentView)
        configure(scrollView, contentView)
        return scrollView
    }
}
