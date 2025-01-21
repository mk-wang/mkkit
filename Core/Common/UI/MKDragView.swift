//
//  MKDragView.swift
//  MKKit
//
//  Created by MK on 2023/5/24.
//

#if canImport(OpenCombine)
    import OpenCombine
#elseif canImport(Combine)
    import Combine
#endif
import UIKit

// MARK: - MKDragView

open class MKDragView: UIView {
    fileprivate let offsetSubject: CurrentValueSubject<CGFloat, Never> = .init(0)
    public lazy var offsetPublisher = offsetSubject.eraseToAnyPublisher()

    var heightOffset: CGFloat {
        offsetSubject.value
    }

    // configuration
    open var heightConfig: HeightConfig = .screenConfig
    open var dragToExpand: Bool = true

    open var contentViewBuilder: ((MKDragView) -> UIView?)?
    open var onClose: VoidFunction?

    public private(set) weak var contentView: UIView?
    private(set) weak var touchView: UIView?

    public var checkMidPosiotionOnDragEnd: Bool = true
    public var canDragDownToMin: Bool = true

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

            NSLayoutConstraint.activate([
                contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

            if let touchView = makeTouchView() {
                touchView.translatesAutoresizingMaskIntoConstraints = false
                addSubview(touchView)
                self.touchView = touchView

                NSLayoutConstraint.activate([
                    touchView.topAnchor.constraint(equalTo: topAnchor),
                    touchView.leadingAnchor.constraint(equalTo: leadingAnchor),
                    touchView.trailingAnchor.constraint(equalTo: trailingAnchor),
                    touchView.bottomAnchor.constraint(equalTo: contentView.topAnchor),
                ])
            }

            contentHeightConstraint = contentView.heightAnchor.constraint(equalToConstant: heightConfig.containerHeight)
            contentHeightConstraint?.isActive = true
        }
    }

    open func hideView() {
        onClose?()
    }

    // https://github.com/xmhafiz/CustomModalVC/blob/main/HalfScreenPresentation/CustomModalViewController.swift
    @objc open func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let contentView else {
            return
        }
        let state = gesture.state

        let offset: CGFloat = state == .began ? 0 : gesture.translation(in: self).y
        gesture.setTranslation(.zero, in: self)

        let initialHeight = heightConfig.containerHeight

        guard state != .cancelled else {
            setContainerHeight(initialHeight, dragEnd: true)
            return
        }

        guard state == .began || state == .changed || state == .ended else {
            return
        }

        var targetHeight: CGFloat?

        let maximumContainerHeight = heightConfig.maximumContainerHeight
        let minimumContainerHeight = heightConfig.minimumContainerHeight

        let startHeight = (dragContentHeight ?? targetContainerHeight)
        var height = startHeight - offset

        if state == .began {
            dragContentHeight = initialHeight
            targetHeight = height
        } else if state == .changed {
            if height < initialHeight, height >= minimumContainerHeight {
                height = startHeight - offset * heightConfig.minHeightOffsetRatio
            }
            if height <= maximumContainerHeight, height >= minimumContainerHeight {
                targetHeight = height
            }
        } else {
            let isDraggingUp = gesture.velocity(in: gesture.view!).y < 0

            let midHeight = (initialHeight + maximumContainerHeight) / 2

            if let dismissibleHeight = heightConfig.dismissibleHeight,
               height <= dismissibleHeight
            { // below dissmiss
                hideView()
                return
            }

            if checkMidPosiotionOnDragEnd {
                let midHeight = (initialHeight + maximumContainerHeight) / 2
                expaneded = height >= midHeight
                targetHeight = expaneded ? maximumContainerHeight : initialHeight
            } else {
                let isDraggingUp = gesture.velocity(in: gesture.view!).y < 0

                if height < initialHeight //  below default
                    || (!isDraggingUp && height < maximumContainerHeight) // below max and going down
                {
                    expaneded = false
                    targetHeight = initialHeight
                } else if height > initialHeight, isDraggingUp { // below max and going up
                    expaneded = true
                    targetHeight = maximumContainerHeight
                }
            }
        }

        if var targetHeight {
            if !dragToExpand, targetHeight > initialHeight {
                targetHeight = initialHeight
            } else if targetHeight < initialHeight, !canDragDownToMin {
                targetHeight = initialHeight
            }
            setContainerHeight(targetHeight, dragEnd: gesture.state == .ended)
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

    @objc open func updateContent(height: CGFloat) {
        offsetSubject.value = height - heightConfig.containerHeight
        contentHeightConstraint?.constant = height
        layoutIfNeeded()
    }

    @objc open func makeTouchView() -> UIView? {
        let box = UIView()
        do {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            box.addGestureRecognizer(gesture)
        }
        return box
    }
}

// MARK: UIGestureRecognizerDelegate

public extension MKDragView {
    var targetContainerHeight: CGFloat {
        expaneded ? heightConfig.maximumContainerHeight : heightConfig.containerHeight
    }

    func onMaxHeight(_ fix: CGFloat = 1) -> Bool {
        guard let height = contentView?.bounds.size.height else {
            return false
        }
        return height + fix > heightConfig.maximumContainerHeight
    }

    func onInitalHeight(_ fix: CGFloat = 0.5) -> Bool {
        guard let height = contentView?.bounds.size.height else {
            return false
        }
        return abs(height - heightConfig.containerHeight) < fix
    }

    func onMinHeight(_ fix: CGFloat = 1) -> Bool {
        guard let height = contentView?.bounds.size.height else {
            return false
        }
        return height - fix < heightConfig.minimumContainerHeight
    }
}

// MARK: UIGestureRecognizerDelegate

extension MKDragView: UIGestureRecognizerDelegate {
    override open func gestureRecognizerShouldBegin(_: UIGestureRecognizer) -> Bool {
        true
    }
}

// MARK: MKDragView.HeightConfig

public extension MKDragView {
    struct HeightConfig {
        public var containerHeight: CGFloat
        public var maximumContainerHeight: CGFloat
        public var minimumContainerHeight: CGFloat
        public var dismissibleHeight: CGFloat?
        public var minHeightOffsetRatio: CGFloat = 0.45

        public static var screenConfig: Self {
            let full = ScreenUtil.screenSize.height
            let maxHeight = full - ScreenUtil.topSafeArea - 10.rw
            return .init(containerHeight: full * 0.64,
                         maximumContainerHeight: min(full * 0.9, maxHeight),
                         minimumContainerHeight: ScreenUtil.bottomSafeArea + 40,
                         dismissibleHeight: full * 0.3)
        }

        public init(containerHeight: CGFloat,
                    maximumContainerHeight: CGFloat,
                    minimumContainerHeight: CGFloat,
                    dismissibleHeight: CGFloat? = nil)
        {
            self.containerHeight = containerHeight
            self.maximumContainerHeight = maximumContainerHeight
            self.minimumContainerHeight = minimumContainerHeight
            self.dismissibleHeight = dismissibleHeight
        }
    }
}
