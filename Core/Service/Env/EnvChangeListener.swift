//
//  EnvChangeListener.swift

//
//  Created by MK on 2021/7/28.
//

import OpenCombine
import OpenCombineFoundation
import UIKit

// MARK: - ThemeChangeListener

public protocol ThemeChangeListener {
    func onThemeChange(isDark: Bool)
}

public extension ThemeChangeListener where Self: AnyObject {
    func subjectThemeChange() -> AnyCancellable {
        AppTheme.darkPublisher.sink { [weak self] isDark in
            self?.onThemeChange(isDark: isDark ?? false)
        }
    }
}

// MARK: - KeyboardChangeListener

public protocol KeyboardChangeListener {
    //   let animationOptions = UIView.AnimationOptions(rawValue:curve)
    func onKeyboardChange(notification: Notification,
                          hideKeyboard: Bool,
                          keyboardSize: CGSize,
                          duration: Double?,
                          curve: UInt?)
}

extension KeyboardChangeListener where Self: AnyObject {
    func handleKeyboardChange(_ notification: Notification) {
        let userInfo = notification.userInfo
        var size = CGSize.zero
        if let keyboardValue = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            size = keyboardValue.cgRectValue.size
        }

        let hide = notification.name == UIResponder.keyboardWillHideNotification
        let duration = (userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue

        var curve: UInt? = nil
        if let raw = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt {
            curve = raw << 16
        }
        onKeyboardChange(notification: notification, hideKeyboard: hide, keyboardSize: size, duration: duration, curve: curve)
    }

    // OpenCombine 还不支持 Publishers Merge
    public func subjectKeyboardChange() -> (Set<AnyCancellable>, AnyPublisher<Notification, Never>) {
        var cancellableSet = Set<AnyCancellable>()

        let noteSubject = PassthroughSubject<Notification, Never>()

        let centerCombine = NotificationCenter.default.ocombine
        do {
            let publisher = centerCombine.publisher(for: UIResponder.keyboardWillHideNotification, object: nil)
            publisher.sink(receiveValue: { [weak self] note in
                noteSubject.send(note)
                self?.handleKeyboardChange(note)
            }).store(in: &cancellableSet)
        }

        do {
            let publisher = centerCombine.publisher(for: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            publisher.sink(receiveValue: { [weak self] note in
                noteSubject.send(note)
                self?.handleKeyboardChange(note)
            }).store(in: &cancellableSet)
        }

        return (cancellableSet, noteSubject.eraseToAnyPublisher())
    }
}
