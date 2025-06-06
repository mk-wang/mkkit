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
        case offset(CGFloat) // 对下个 view 起作用
        case space(CGFloat? = nil, flex: CGFloat = 1, min: CGFloat? = nil, max: CGFloat? = nil)
        case view(UIView?,
                  width: CGFloat? = nil,
                  height: CGFloat? = nil,
                  minWidth: CGFloat? = nil,
                  minHeight: CGFloat? = nil,
                  size: CGSize? = nil,
                  crossCenter: Bool = false,
                  crossInset: CGFloat? = nil,
                  crossInsets: UIEdgeInsets? = nil,
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

        var lastOffset: CGFloat?

        for builder in builders {
            var snpObject: SnpLayoutObject?
            var isOffset = false
            switch builder {
            case let .offset(size):
                lastOffset = size
                isOffset = true
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
                           crossInset,
                           crossInsets,
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

                    if let crossInset {
                        if direction == .vertical {
                            make.horizontalEdges.equalToSuperview().inset(crossInset)
                        } else {
                            make.verticalEdges.equalToSuperview().inset(crossInset)
                        }
                    }

                    if let crossInsets {
                        if direction == .vertical {
                            make.horizontalEdges.equalToSuperview().inset(crossInsets)
                        } else {
                            make.verticalEdges.equalToSuperview().inset(crossInsets)
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
                let offset = lastOffset ?? 0
                lastOffset = nil
                snpObject.addSnpConfig { _, make in
                    if let snp = lastObject?.snpDSL {
                        switch direction {
                        case .vertical:
                            make.top.equalTo(snp.bottom).offset(offset)
                        case .horizontal:
                            make.leading.equalTo(snp.trailing).offset(offset)
                        case .ltrHorizontal:
                            make.left.equalTo(snp.right).offset(offset)
                        }
                    } else {
                        switch direction {
                        case .vertical:
                            make.top.equalToSuperview().offset(offset)
                        case .horizontal:
                            make.leading.equalToSuperview().offset(offset)
                        case .ltrHorizontal:
                            make.left.equalToSuperview().offset(offset)
                        }
                    }
                }
                addSnpObject(snpObject)
                lastObject = snpObject
            } else if !isOffset, lastOffset != nil {
                lastOffset = nil
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
