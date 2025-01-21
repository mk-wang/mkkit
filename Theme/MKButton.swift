//
//  MKButton.swift
//
//
//  Created by MK on 2022/5/10.
//

import UIKit

// MARK: - MKButton

open class MKButton: UIButton {
    open var tapExt: CGSize? = nil

    open var themeTintColor: UIColor?
    open var themeCancellable: AnyCancellableType?

    open var onLayout: VoidFunction?
    open var onCheckBackgroundColor: VoidFunction2<Bool, Bool>?

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
            handleHighlightState(highLighted: isHighlighted)
        }
    }

    override open var isEnabled: Bool {
        didSet {
            checkBackgroundColor()
        }
    }

    public func checkBackgroundColor() {
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

        onCheckBackgroundColor?(isEnabled, isHighlighted)
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

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var inside = super.point(inside: point, with: event)
        guard !inside, let tapExt else {
            return inside
        }

        let rect = bounds.insetBy(dx: -tapExt.width, dy: -tapExt.height)
        inside = rect.contains(point)

        return inside
    }

    override public init(frame: CGRect) {
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

extension MKButton: ThemeChangeListener {
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

public extension MKButton {
    static func makeButton(type: UIButton.ButtonType = .custom,
                           size: CGSize,
                           style: ButtonViewStyle? = nil,
                           tapExt: CGSize = .square(10),
                           image originImage: UIImage? = nil,
                           url: URL? = nil,
                           langFlip: Bool = false,
                           tintColor: UIColor? = nil) -> MKButton
    {
        let btn = style == nil ? MKButton(type: type) : MKButton(type: type, style: style!)
        btn.tapExt = tapExt
        var image = originImage
        if image == nil, let url {
            image = svgImage(url: url,
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

            if let color = style?.highlightedImageColor {
                let tinted = image.tint(color: color)
                btn.setImage(tinted, for: .highlighted)
            }

            if let color = style?.disabledColor {
                let tinted = image.tint(color: color)
                btn.setImage(tinted, for: .disabled)
            }
        }

        return btn
    }
}

public extension UIButton {
    convenience init(type: UIButton.ButtonType, style: ButtonViewStyle) {
        self.init(type: type)

        titleLabel?.font = style.font
        setTitleColor(style.color, for: .normal)

        titleLabel?.textAlignment = style.textAlignment
        backgroundColor = style.backgroundColor

        if let color = style.highlightedTextColor {
            setTitleColor(color, for: .highlighted)
        }
        if let btn = self as? MKButton {
            btn.setBackgroundColor(style.highlightedBackgroundColor, for: .highlighted)
            btn.setBackgroundColor(style.backgroundColor, for: .normal)
        }
    }
}
