//
//  UIDatePickerExt.swift
//  MKKit
//
//  Created by MK on 2023/7/25.
//

import UIKit

public extension UIDatePicker {
    func disableKeyboardInput() {
        addTarget(self, action: #selector(__handleDatePickerTap__), for: .editingDidBegin)
    }

    @objc private func __handleDatePickerTap__() {
        resignFirstResponder()
    }
}
