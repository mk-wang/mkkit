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
                     builders: [SnpStackViewBuilder])
    {
        self.init(frame: .zero)
        addSnpStackSubviews(direction, builders: builders)
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
                             builders: [SnpStackViewBuilder])
    {
        weak var lastObject: SnpLayoutObject?
        var flexValue: CGFloat = 1
        weak var flexObject: SnpLayoutObject?

        for builder in builders {
            var snpObject: SnpLayoutObject?

            switch builder {
            case let .space(size, flex):
                #if DEBUG // && targetEnvironment(simulator)
                    snpObject = UIView()
                #else
                    snpObject = UILayoutGuide()
                #endif

                snpObject?.addSnpConfig { [weak snpObject] _, make in
                    let crossAxis = direction == .vertical ? make.width : make.height
                    let crossCenter = direction == .vertical ? make.centerX : make.centerY

                    crossAxis.equalTo(0)
                    crossCenter.equalToSuperview()

                    let mainAxis = direction == .vertical ? make.height : make.width
                    if let size {
                        mainAxis.equalTo(size)
                    } else if flex > 0 {
                        if let flexObject {
                            let target = direction == .vertical ? flexObject.snpDSL.height : flexObject.snpDSL.width
                            mainAxis.equalTo(target).multipliedBy(flex / flexValue)
                        } else {
                            flexObject = snpObject
                            flexValue = flex
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
            switch direction {
            case .vertical:
                make.bottom.equalToSuperview()
            case .horizontal:
                make.trailing.equalToSuperview()
            case .ltrHorizontal:
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
