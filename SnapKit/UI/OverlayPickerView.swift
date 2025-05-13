import MKKit13
import UIKit

// MARK: - OverlayPickerView

open class OverlayPickerView: MKBaseView {
    public struct Config {
        let numberOfComponents: ValueBuilder1<Int, OverlayPickerView>
        let numberOfRows: ValueBuilder2<Int, OverlayPickerView, Int>
        let rowHeight: ValueBuilder2<CGFloat, OverlayPickerView, Int>

        let viewForRow: ValueBuilder4<UIView?, OverlayPickerView, Int, Int, UIView?>
        let selectedHanlder: VoidFunction3<OverlayPickerView, Int, Int>?

        public init(numberOfComponents: @escaping ValueBuilder1<Int, OverlayPickerView>,
                    numberOfRows: @escaping ValueBuilder2<Int, OverlayPickerView, Int>,
                    rowHeight: @escaping ValueBuilder2<CGFloat, OverlayPickerView, Int>,
                    viewForRow: @escaping ValueBuilder4<UIView?, OverlayPickerView, Int, Int, UIView?>,
                    selectedHanlder: VoidFunction3<OverlayPickerView, Int, Int>? = nil)
        {
            self.numberOfComponents = numberOfComponents
            self.numberOfRows = numberOfRows
            self.rowHeight = rowHeight
            self.viewForRow = viewForRow
            self.selectedHanlder = selectedHanlder
        }
    }

    public let config: Config

    // MARK: - Private Properties

    private var hasChangedSeparator = false
    private var overlayView: UIView?

    public init(config: Config, frame: CGRect) {
        self.config = config
        super.init(frame: frame)
    }

    private lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .clear
        picker.delegate = self
        picker.dataSource = self

        picker.addSnpConfig { [weak self] _, make in
            make.center.equalToSuperview()
            make.size.equalTo(self?.pickerSizeBuilder() ?? .zero)
        }

        return picker
    }()

    private lazy var pickerSizeBuilder: ValueBuilder<CGSize> = { [weak self] in
        guard let self else {
            return .zero
        }
        return frame.size
    }

    override open func readyToLayout() {
        super.readyToLayout()
        addSnpSubview(picker)
        if let overlayView {
            addSnpSubview(overlayView)
        }
    }
}

public extension OverlayPickerView {
    @objc func addOverlay(size: CGSize, viewBuilder: ValueBuilder<UIView?>) {
        overlayView?.removeFromSuperview()
        guard let view = viewBuilder() else {
            overlayView = nil
            return
        }
        view.addSnpConfig { _, make in
            make.size.equalTo(size)
            make.center.equalToSuperview()
        }
        if picker.superview != nil {
            addSnpSubview(view)
        }
        overlayView = view
    }

    @objc func selectRow(_ row: Int, inComponent component: Int, animated: Bool) {
        picker.selectRow(row, inComponent: component, animated: animated)
    }

    @objc func selectedRow(inComponent component: Int) -> Int {
        picker.selectedRow(inComponent: component)
    }

    @objc func reloadAllComponents() {
        picker.reloadAllComponents()
    }

    @objc func reloadComponent(_ component: Int) {
        picker.reloadComponent(component)
    }

    @objc func updatePicker(size: CGSize) {
        pickerSizeBuilder = {
            size
        }
        if picker.superview != nil {
            picker.snp.updateConstraints { make in
                make.size.equalTo(size)
            }
        }
    }
}

// MARK: UIPickerViewDataSource

extension OverlayPickerView: UIPickerViewDataSource {
    public func numberOfComponents(in _: UIPickerView) -> Int {
        config.numberOfComponents(self)
    }

    public func pickerView(_: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        config.numberOfRows(self, component)
    }
}

// MARK: UIPickerViewDelegate

extension OverlayPickerView: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView,
                           viewForRow row: Int,
                           forComponent component: Int,
                           reusing view: UIView?) -> UIView
    {
        if !hasChangedSeparator {
            hasChangedSeparator = true
            pickerView.hideSeparator()
        }

        return config.viewForRow(self, row, component, view) ?? .init()
    }

    public func pickerView(_: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        config.rowHeight(self, component)
    }

    public func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        config.selectedHanlder?(self, row, component)
    }
}

public extension UIPickerView {
    @objc func hideSeparator() -> Bool {
        if #available(iOS 14.0, *) {
            guard let subview = subviews.at(1) else {
                return false
            }
            subview.isHidden = true
            return true
        } else {
            let list = subviews.filter { $0.frame.height <= 2 }
            guard !list.isEmpty else {
                return false
            }
            list.forEach { $0.isHidden = true }
            return true
        }
    }
}
