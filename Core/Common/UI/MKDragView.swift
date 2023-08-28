//
//  MKDragView.swift
//  MKKit
//
//  Created by MK on 2023/5/24.
//

import UIKit

// MARK: - MKDragView

open class MKDragView: UIView {
    public struct HeightConfig {
        public var containerHeight: CGFloat
        public var dismissibleHeight: CGFloat
        public var maximumContainerHeight: CGFloat

        public static var screenConfig: Self {
            let full = ScreenUtil.screenSize.height
            let maxHeight = full - ScreenUtil.topSafeArea - 10.rw
            return .init(containerHeight: full * 0.64,
                         dismissibleHeight: full * 0.3,
                         maximumContainerHeight: min(full * 0.9, maxHeight))
        }
    }

    // configuration
    open var heightConfig: HeightConfig = .screenConfig
    open var dragToExpand: Bool = true
    open var contentViewBuilder: ((MKDragView) -> UIView?)?
    open var onClose: VoidFunction?

    private(set) weak var contentView: UIView?
    private(set) weak var touchView: UIView?

    private(set) var expaneded = false
    private var contentHeightConstraint: NSLayoutConstraint?
    private var dragContentHeight: CGFloat?

    override open func layoutSubviews() {
        super.layoutSubviews()
        guard isReadyToConfig else {
            return
        }

        if let contentView = contentViewBuilder?(self) {
            addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            self.contentView = contentView

            do {
                let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
                //        gesture.delaysTouchesBegan = false
                //        gesture.delaysTouchesEnded = false
                gesture.delegate = self
                contentView.addGestureRecognizer(gesture)
            }

            let touchView = UIView()
            addSubview(touchView)
            touchView.translatesAutoresizingMaskIntoConstraints = false
            self.touchView = touchView
            do {
                let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
                touchView.addGestureRecognizer(gesture)
            }

            NSLayoutConstraint.activate([
                touchView.topAnchor.constraint(equalTo: topAnchor),
                touchView.leadingAnchor.constraint(equalTo: leadingAnchor),
                touchView.trailingAnchor.constraint(equalTo: trailingAnchor),
                touchView.bottomAnchor.constraint(equalTo: contentView.topAnchor),

                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

            contentHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: initialHeight)
            contentHeightConstraint?.isActive = true
        }
    }

    open func hideView() {
        onClose?()
    }

    // https://github.com/xmhafiz/CustomModalVC/blob/main/HalfScreenPresentation/CustomModalViewController.swift
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let contentView else {
            return
        }
        let offset = gesture.translation(in: self).y
        gesture.setTranslation(.zero, in: self)

        let state = gesture.state

        guard state != .cancelled else {
            setContainerHeight(initialHeight, dragEnd: true)
            return
        }

        guard state == .began || state == .changed || state == .ended else {
            return
        }

        var targetHeight: CGFloat?

        let height = (dragContentHeight ?? targetContainerHeight) - offset
        if state == .began {
            dragContentHeight = initialHeight
            targetHeight = height
        } else if state == .changed {
            if height < maximumContainerHeight, height > safeAreaInsets.bottom + 40 {
                targetHeight = height
            }
        } else {
            let isDraggingUp = gesture.velocity(in: gesture.view!).y < 0

            if height < dismissibleHeight { // below min
                hideView()
            } else if height < initialHeight //  below default
                || (!isDraggingUp && height < maximumContainerHeight) // below max and going down
            {
                targetHeight = initialHeight
                expaneded = false
            } else if height > initialHeight, isDraggingUp { // below max and going up
                targetHeight = maximumContainerHeight
                expaneded = true
            }
        }

        if var height = targetHeight {
            if !dragToExpand, height > initialHeight {
                height = initialHeight
            }
            setContainerHeight(height, dragEnd: gesture.state == .ended)
        }
    }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        if gesture.state == .ended {
            hideView()
        }
    }

    func setContainerHeight(_ height: CGFloat, dragEnd: Bool) {
        if dragEnd {
            weak var weakSelf = self

            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.5,
                options: .curveEaseInOut,
                animations: { [weak self] in
                    weakSelf?.updateContent(height: height)
                }
            )

            dragContentHeight = nil
        } else {
            updateContent(height: height)
            dragContentHeight = height
        }
    }

    func updateContent(height: CGFloat) {
        contentHeightConstraint?.constant = height
        layoutIfNeeded()
    }
}

// MARK: UIGestureRecognizerDelegate

public extension MKDragView {
    var targetContainerHeight: CGFloat {
        expaneded ? maximumContainerHeight : initialHeight
    }

    var initialHeight: CGFloat {
        heightConfig.containerHeight
    }

    var maximumContainerHeight: CGFloat {
        heightConfig.maximumContainerHeight
    }

    var dismissibleHeight: CGFloat {
        heightConfig.dismissibleHeight
    }
}

// MARK: UIGestureRecognizerDelegate

extension MKDragView: UIGestureRecognizerDelegate {
    override open func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        true
    }
}
