//
//  SelectedItems.swift
//  MKKit
//
//  Created by MK on 2022/11/29.
//

import Foundation
import OpenCombine

// MARK: - SelectedItems

open class SelectedItems<T> {
    public let removeDuplicates: Bool
    public let list: [T]

    private let subject: CurrentValueSubject<Int?, Never>

    open var selectedIndexPublisher: AnyPublisher<Int?, Never> {
        if removeDuplicates {
            return subject.removeDuplicates().eraseToAnyPublisher()
        } else {
            return subject.eraseToAnyPublisher()
        }
    }

    open var selectedItemPublisher: AnyPublisher<T?, Never> {
        selectedIndexPublisher.map { [weak self] in
            self?.itemAt(index: $0)
        }.eraseToAnyPublisher()
    }

    open var selected: T? {
        itemAt(index: subject.value)
    }

    open var selectedIndex: Int? {
        get {
            subject.value
        }
        set {
            setSelectedIndex(index: newValue)
        }
    }

    open var isEmpty: Bool {
        list.isEmpty
    }

    open var isNotEmpty: Bool {
        list.isNotEmpty
    }

    public init(list: [T], removeDuplicates: Bool = true, selected: Int? = nil) {
        self.removeDuplicates = removeDuplicates
        self.list = list

        subject = CurrentValueSubject<Int?, Never>(selected)
    }

    open func itemAt(index: Int?) -> T? {
        guard let index else {
            return nil
        }
        return list.at(index)
    }

    public private(set) weak var setter: AnyObject?
    public func setSelectedIndex(index: Int?, setter: AnyObject? = nil) {
        if !removeDuplicates || subject.value != index {
            var index = index
            if let val = index {
                if val < 0 || val >= list.count {
                    index = nil
                }
            }
            self.setter = setter
            subject.value = index
        }
    }
}

extension SelectedItems where T: Equatable {
    open var selected: T? {
        get {
            itemAt(index: subject.value)
        }
        set {
            subject.value = list.firstIndex { $0 == newValue }
        }
    }
}
