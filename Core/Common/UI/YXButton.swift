//
//  YXButton.swift
//
//
//  Created by MK on 2022/5/10.
//

import OpenCombine
import UIKit

// MARK: - YXButton

open class YXButton: UIButton {
    open var tapExt = CGSize.zero
    open var onLayout: VoidFunction?
    open var themeTintColor: UIColor?
    open var themeCancellable: AnyCancellable?

    public enum ButtonState {
        case normal
        case highlighted
        case disabled
    }

    open var disabledBackgroundColor: UIColor?
    open var highlightedBackgroundColor: UIColor?
    open var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }

    override open var isHighlighted: Bool {
        didSet {
            checkBackgroundColor()
        }
    }

    override open var isEnabled: Bool {
        didSet {
            checkBackgroundColor()
        }
    }

    func checkBackgroundColor() {
        if isEnabled {
            if isHighlighted, let highlightedBackgroundColor {
                backgroundColor = highlightedBackgroundColor
            } else if !isHighlighted, let defaultBackgroundColor {
                backgroundColor = defaultBackgroundColor
            }
        } else {
            if let disabledBackgroundColor {
                backgroundColor = disabledBackgroundColor
            }
        }
    }

    public func setBackgroundColor(_ color: UIColor?, for state: ButtonState) {
        switch state {
        case .disabled:
            disabledBackgroundColor = color
        case .highlighted:
            highlightedBackgroundColor = color
        case .normal:
            defaultBackgroundColor = color
        }
    }

    override open func point(inside point: CGPoint, with _: UIEvent?) -> Bool {
        bounds.insetBy(dx: -tapExt.width, dy: -tapExt.height).contains(point)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        themeCancellable = subjectThemeChange()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if let cb = onLayout {
            cb()
        }
    }
}

// MARK: ThemeChangeListener

extension YXButton: ThemeChangeListener {
    public func onThemeChange(isDark _: Bool) {
        guard !subviews.isEmpty,
              let tintColor = themeTintColor
        else {
            return
        }

        // fix ios 11 - 12
        if !AppTheme.isSytemSupported {
            let image = image(for: .normal)?.tint(color: tintColor)
            setImage(image, for: .normal)
        }
    }
}

public extension YXButton {
    static func makeButton(type: UIButton.ButtonType = .custom,
                           size: CGSize,
                           style: ButtonViewStyle? = nil,
                           image originImage: UIImage? = nil,
                           path: String? = nil,
                           langFlip: Bool = false,
                           tintColor: UIColor? = nil) -> YXButton
    {
        let btn = style == nil ? YXButton(type: type) : YXButton(type: type, style: style!)
        btn.tapExt = CGSize(10, 10)

        var image = originImage
        if image == nil, let path {
            image = svgImage(path: path,
                             size: size)
        }

        if image != nil, langFlip {
            image = image?.langFlip
        }

        if let image {
            do {
                var normal = image
                if let color = tintColor {
                    normal = normal.tint(color: color)
                }
                btn.setImage(normal, for: .normal)
            }

            if let color = style?.highlightedBackgroundColor {
                var highlighted = image
                highlighted = highlighted.tint(color: color)
                btn.setImage(highlighted, for: .highlighted)
            }
        }

        return btn
    }
}
