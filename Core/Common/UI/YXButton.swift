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
    var tapExt = CGSize.zero
    var onLayout: VoidFunction?
    var themeTintColor: UIColor?
    var themeCancellable: AnyCancellable?

    enum ButtonState {
        case normal
        case disabled
    }

    var disabledBackgroundColor: UIColor?
    var defaultBackgroundColor: UIColor? {
        didSet {
            backgroundColor = defaultBackgroundColor
        }
    }

    override open var isEnabled: Bool {
        didSet {
            if isEnabled {
                if let color = defaultBackgroundColor {
                    backgroundColor = color
                }
            } else {
                if let color = disabledBackgroundColor {
                    backgroundColor = color
                }
            }
        }
    }

    func setBackgroundColor(_ color: UIColor?, for state: ButtonState) {
        switch state {
        case .disabled:
            disabledBackgroundColor = color
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
    func onThemeChange(isDark _: Bool) {
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
