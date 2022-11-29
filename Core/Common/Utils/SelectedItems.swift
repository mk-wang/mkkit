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
    private let subject: CurrentValueSubject<Int, Never>

    public lazy var selectedIndexPublisher: AnyPublisher<Int, Never> = subject.removeDuplicates().eraseToAnyPublisher()

    public lazy var selectedItemPublisher: AnyPublisher<T, Never> = {
        let list = self.list
        return subject.removeDuplicates().map { idx in
            list[idx]
        }.eraseToAnyPublisher()
    }()

    open var selected: T {
        list[subject.value]
    }

    open var selectedIndex: Int {
        get {
            subject.value
        }
        set {
            if subject.value != newValue {
                var index = newValue
                if index < 0 || index >= list.count {
                    index = 0
                }
                subject.value = index
            }
        }
    }

    public init(selected: Int, list: [T]) {
        self.list = list
        var index = selected
        if index < 0 || index >= list.count {
            index = 0
        }
        subject = CurrentValueSubject<Int, Never>(index)
    }
}
