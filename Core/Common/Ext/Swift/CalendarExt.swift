//
//  CalendarExt.swift
//  MKKit
//
//  Created by MK on 2024/1/5.
//

import Foundation

// MARK: - Enums

public extension Calendar {
    var numberOfWeekdays: Int {
        maximumRange(of: .weekday)?.count ?? 7
    }

    var firstWeekdayIndex: Int { firstWeekday - 1 }

    func weekday(of index: Int) -> Int {
        let day = index + firstWeekdayIndex
        return (day % numberOfWeekdays) + 1
    }
}
