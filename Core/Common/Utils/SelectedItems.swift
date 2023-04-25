//
//  SelectedItems.swift
//  MKKit
//
//  Created by MK on 2022/11/29.
//

import Foundation
import OpenCombine

open class SelectedItems<T> {
    public let list: [T]
    private let subject: CurrentValueSubject<Int?, Never>
    public lazy var selectedIndexPublisher: AnyPublisher<Int?, Never> = subject.removeDuplicates().eraseToAnyPublisher()

    public lazy var selectedItemPublisher: AnyPublisher<T?, Never> = subject.removeDuplicates().map { [weak self] in
        self?.itemAt(index: $0)
    }.eraseToAnyPublisher()

    open var selected: T? {
        itemAt(index: subject.value)
    }

    open var selectedIndex: Int? {
        get {
            subject.value
        }
        set {
            if subject.value != newValue {
                var index = newValue
                if let val = newValue {
                    if val < 0 || val >= list.count {
                        index = nil
                    }
                }
                subject.value = index
            }
        }
    }

    open var isEmpty: Bool {
        list.isEmpty
    }

    open var isNotEmpty: Bool {
        list.isNotEmpty
    }

    public init(list: [T], selected: Int? = nil) {
        self.list = list

        subject = CurrentValueSubject<Int?, Never>(selected)
    }

    open func itemAt(index: Int?) -> T? {
        guard let index else {
            return nil
        }
        return list.at(index)
    }
}
