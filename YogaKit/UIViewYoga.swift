//
//  UIViewYoga.swift
//
//
//  Created by MK on 2022/3/27.
//

import UIKit
import YogaKit

public extension UIView {
    enum YGViewBuilder {
        case view(UIView?, YGLayoutConfigurationBlock? = nil)
        case subviews([YGViewBuilder], layoutConfig: YGLayoutConfigurationBlock? = nil)
        case builder((UIView?) -> UIView?)
        case width(CGFloat)
        case height(CGFloat)
        case sizedBox(width: CGFloat?, height: CGFloat?)
        case space(CGFloat = 1)
    }

    func addYGSubviews(_ builders: [YGViewBuilder]) {
        yoga.isEnabled = true
        for builder in builders {
            var view: UIView?
            switch builder {
            case let .view(subView, config):
                view = subView
                if let view, let config {
                    view.configureLayout { layout in
                        layout.isEnabled = true
                        config(layout)
                    }
                }
            case let .builder(viewBuilder):
                view = viewBuilder(self)
            case let .subviews(builders, layoutConfig: config):
                view = UIView(ygBuilders: builders, layoutConfig: config)
            case let .sizedBox(width: width, height: height):
                view = UIView.ygSizedBox(width: width, height: height)
            case let .width(val):
                view = UIView.ygSizedBox(width: val)
            case let .height(val):
                view = UIView.ygSizedBox(height: val)
            case let .space(val):
                view = UIView.ygSpace(flex: val)
            }

            if let view {
                addSubview(view)
            }
        }
    }

    convenience init(ygBuilders: [YGViewBuilder],
                     layoutConfig: YGLayoutConfigurationBlock? = nil)
    {
        self.init()

        configureLayout { layout in
            layout.isEnabled = true
            if let configuration = layoutConfig {
                configuration(layout)
            }
        }

        addYGSubviews(ygBuilders)
    }
}

public extension UIView {
    class func ygSizedBox(width: CGFloat? = nil, height: CGFloat? = nil) -> UIView {
        let view = UIView()
        view.configureLayout { layout in
            layout.isEnabled = true
            if let width {
                layout.width = width.yg
            }

            if let height {
                layout.height = height.yg
            }
        }
        return view
    }

    class func ygSpace(flex: CGFloat = 1) -> UIView {
        let view = UIView()
        view.configureLayout { layout in
            layout.isEnabled = true
            layout.flex = flex
        }
        return view
    }

    class func centerBox() -> UIView {
        let view = UIView()
        view.configureLayout { layout in
            layout.isEnabled = true
            layout.start = 0
            layout.end = 0
            layout.top = 0
            layout.bottom = 0
            layout.position = .absolute
            layout.justifyContent = .center
            layout.alignItems = .center
        }
        return view
    }
}
