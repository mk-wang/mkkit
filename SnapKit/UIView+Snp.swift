//
//  UIView+Snp.swift
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
        case space(CGFloat? = nil, flex: CGFloat = 1, min: CGFloat? = nil, max: CGFloat? = nil)
        case view(UIView?,
                  width: CGFloat? = nil,
                  height: CGFloat? = nil,
                  minWidth: CGFloat? = nil,
                  minHeight: CGFloat? = nil,
                  size: CGSize? = nil,
                  crossCenter: Bool = false,
                  crossEdgesInset: CGFloat? = nil,
                  tight: Bool = false)
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
            case let .space(size, flex, min, max):
                snpObject = UILayoutGuide()

                snpObject?.addSnpConfig { [weak snpObject] _, make in
                    let crossAxis = direction == .vertical ? make.width : make.height
                    let crossCenter = direction == .vertical ? make.centerX : make.centerY

                    crossAxis.equalTo(0)
                    crossCenter.equalToSuperview()

                    let mainAxis = direction == .vertical ? make.height : make.width
                    if let size {
                        mainAxis.equalTo(size)
                    } else {
                        if let min {
                            mainAxis.greaterThanOrEqualTo(min)
                        }

                        if let max {
                            mainAxis.lessThanOrEqualTo(max)
                        }

                        if flex > 0 {
                            if let flexObject {
                                let target = direction == .vertical ? flexObject.snpDSL.height : flexObject.snpDSL.width
                                mainAxis.equalTo(target).multipliedBy(flex / flexValue)
                            } else {
                                flexObject = snpObject
                                flexValue = flex
                            }
                        }
                    }
                }
            case let .view(aView,
                           width,
                           height,
                           minWidth,
                           minHeight,
                           size,
                           crossCenter,
                           crossEdgesInset,
                           tight):
                aView?.addSnpConfig { _, make in
                    if let width {
                        make.width.equalTo(width)
                    }
                    if let height {
                        make.height.equalTo(height)
                    }
                    if let minWidth {
                        make.width.greaterThanOrEqualTo(minWidth)
                    }
                    if let minHeight {
                        make.height.greaterThanOrEqualTo(minHeight)
                    }
                    if let size {
                        make.size.equalTo(size)
                    }
                    if crossCenter {
                        if direction == .vertical {
                            make.centerX.equalToSuperview()
                        } else {
                            make.centerY.equalToSuperview()
                        }
                    }

                    if let crossEdgesInset {
                        if direction == .vertical {
                            make.horizontalEdges.equalToSuperview().inset(crossEdgesInset)
                        } else {
                            make.verticalEdges.equalToSuperview().inset(crossEdgesInset)
                        }
                    }
                }
                if tight {
                    aView?.compressionLayout(for: direction == .vertical ? .vertical : .horizontal)
                }
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
        scrollView.addSnpEdgesToSuper()
        scrollView.contentInsetAdjustmentBehavior = .never
        addSnpSubview(scrollView)

        let contentView = UIView()
        contentView.addSnpConfig { [unowned(unsafe) self] _, make in
            if vertical {
                make.verticalEdges.equalToSuperview()
                make.horizontalEdges.equalTo(self)
            } else {
                make.horizontalEdges.equalToSuperview()
                make.verticalEdges.equalTo(self)
            }
        }
        scrollView.addSnpSubview(contentView)
        configure(scrollView, contentView)
        return scrollView
    }
}
