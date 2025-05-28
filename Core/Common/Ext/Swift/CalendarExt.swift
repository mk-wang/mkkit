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

public extension Calendar {
    /// Returns true if the first date is in the same day as or before the second date (ignoring time components).
    /// - Parameters:
    ///   - date1: The first date to compare.
    ///   - date2: The second date to compare.
    /// - Returns: True if date1 is in the same day as or before date2.
    func isDate(_ date1: Date, inSameDayAsOrBefore date2: Date) -> Bool {
        let startOfDay1 = startOfDay(for: date1)
        let startOfDay2 = startOfDay(for: date2)
        return startOfDay1 <= startOfDay2
    }
}
