//
//  DateExt.swift
//
//
//  Created by MK on 2021/7/23.
//

import Darwin
import Foundation

// MARK: - Enums

public extension Date {
    func add(day: Int) -> Self {
        .init(timeIntervalSinceReferenceDate: timeIntervalSinceReferenceDate + TimeInterval(day) * Self.oneDayInterval)
    }

    func beginningOfWeek(_ calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        components.weekday = calendar.firstWeekday
        return calendar.date(from: components)!
    }

    var timePassed: TimeInterval {
        -timeIntervalSinceNow
    }

    static let oneMinuteInterval: TimeInterval = 60
    static let oneHourInterval: TimeInterval = 60 * oneMinuteInterval
    static let oneDayInterval: TimeInterval = 24 * oneHourInterval
}

public extension Date {
    /// SwifterSwift: Day name format.
    ///
    /// - threeLetters: 3 letter day abbreviation of day name.
    /// - oneLetter: 1 letter day abbreviation of day name.
    /// - full: Full day name.
    enum DayNameStyle {
        /// SwifterSwift: 3 letter day abbreviation of day name.
        case threeLetters

        /// SwifterSwift: 1 letter day abbreviation of day name.
        case oneLetter

        /// SwifterSwift: Full day name.
        case full
    }

    /// SwifterSwift: Month name format.
    ///
    /// - threeLetters: 3 letter month abbreviation of month name.
    /// - oneLetter: 1 letter month abbreviation of month name.
    /// - full: Full month name.
    enum MonthNameStyle {
        /// SwifterSwift: 3 letter month abbreviation of month name.
        case threeLetters

        /// SwifterSwift: 1 letter month abbreviation of month name.
        case oneLetter

        /// SwifterSwift: Full month name.
        case full
    }
}

// MARK: - Properties

public extension Date {
//    /// SwifterSwift: User’s current calendar.
//    var calendar: Calendar {
//        // Workaround to segfault on corelibs foundation https://bugs.swift.org/browse/SR-10147
//        Calendar(identifier: Calendar.current.identifier)
//    }

    /// SwifterSwift: Era.
    ///
    ///        Date().era -> 1
    ///
    func era(_ calendar: Calendar = .current) -> Int {
        calendar.component(.era, from: self)
    }

    /// SwifterSwift: Quarter.
    ///
    ///        Date().quarter -> 3 // date in third quarter of the year.
    ///
    func quarter(_ calendar: Calendar = .current) -> Int {
        let month = Double(calendar.component(.month, from: self))
        let numberOfMonths = Double(calendar.monthSymbols.count)
        let numberOfMonthsInQuarter = numberOfMonths / 4
        return Int(ceil(month / numberOfMonthsInQuarter))
    }

    /// SwifterSwift: Week of year.
    ///
    ///        Date().weekOfYear -> 2 // second week in the year.
    ///
    func weekOfYear(_ calendar: Calendar = .current) -> Int {
        calendar.component(.weekOfYear, from: self)
    }

    /// SwifterSwift: Week of month.
    ///
    ///        Date().weekOfMonth -> 3 // date is in third week of the month.
    ///
    func weekOfMonth(_ calendar: Calendar = .current) -> Int {
        calendar.component(.weekOfMonth, from: self)
    }

    /// SwifterSwift: Year.
    ///
    ///        Date().year -> 2017
    ///
    ///        var someDate = Date()
    ///        someDate.year = 2000 // sets someDate's year to 2000
    ///
    ///
    func year(_ calendar: Calendar = .current) -> Int {
        calendar.component(.year, from: self)
    }

    mutating func update(year: Int, _ calendar: Calendar = .current) {
        guard year > 0 else { return }
        let currentYear = calendar.component(.year, from: self)
        let yearsToAdd = year - currentYear
        if let date = calendar.date(byAdding: .year, value: yearsToAdd, to: self) {
            self = date
        }
    }

    /// SwifterSwift: Month.
    ///
    ///     Date().month -> 1
    ///
    ///     var someDate = Date()
    ///     someDate.month = 10 // sets someDate's month to 10.
    ///
    ///
    func month(_ calendar: Calendar = .current) -> Int {
        calendar.component(.month, from: self)
    }

    mutating func update(month: Int, _ calendar: Calendar = .current) {
        let allowedRange = calendar.range(of: .month, in: .year, for: self)!
        guard allowedRange.contains(month) else { return }

        let currentMonth = calendar.component(.month, from: self)
        let monthsToAdd = month - currentMonth
        if let date = calendar.date(byAdding: .month, value: monthsToAdd, to: self) {
            self = date
        }
    }

    /// SwifterSwift: Day.
    ///
    ///     Date().day -> 12
    ///
    ///     var someDate = Date()
    ///     someDate.day = 1 // sets someDate's day of month to 1.
    ///
    ///
    func day(_ calendar: Calendar = .current) -> Int {
        calendar.component(.day, from: self)
    }

    mutating func update(day: Int, _ calendar: Calendar = .current) {
        let allowedRange = calendar.range(of: .day, in: .month, for: self)!
        guard allowedRange.contains(day) else { return }

        let currentDay = calendar.component(.day, from: self)
        let daysToAdd = day - currentDay
        if let date = calendar.date(byAdding: .day, value: daysToAdd, to: self) {
            self = date
        }
    }

    /// SwifterSwift: Weekday.
    ///
    ///     Date().weekday -> 5 // fifth day in the current week.
    ///
    func weekday(_ calendar: Calendar = .current) -> Int {
        calendar.component(.weekday, from: self)
    }

    /// SwifterSwift: Hour.
    ///
    ///     Date().hour -> 17 // 5 pm
    ///
    ///     var someDate = Date()
    ///     someDate.hour = 13 // sets someDate's hour to 1 pm.

    func hour(_ calendar: Calendar = .current) -> Int {
        calendar.component(.hour, from: self)
    }

    mutating func update(hour: Int, _ calendar: Calendar = .current) {
        let allowedRange = calendar.range(of: .hour, in: .day, for: self)!
        guard allowedRange.contains(hour) else { return }

        let currentHour = calendar.component(.hour, from: self)
        let hoursToAdd = hour - currentHour
        if let date = calendar.date(byAdding: .hour, value: hoursToAdd, to: self) {
            self = date
        }
    }

    /// SwifterSwift: Minutes.
    ///
    ///     Date().minute -> 39
    ///
    ///     var someDate = Date()
    ///     someDate.minute = 10 // sets someDate's minutes to 10.

    func minute(_ calendar: Calendar = .current) -> Int {
        calendar.component(.minute, from: self)
    }

    mutating func update(minute: Int, _ calendar: Calendar = .current) {
        let allowedRange = calendar.range(of: .minute, in: .hour, for: self)!
        guard allowedRange.contains(minute) else { return }

        let currentMinutes = calendar.component(.minute, from: self)
        let minutesToAdd = minute - currentMinutes
        if let date = calendar.date(byAdding: .minute, value: minutesToAdd, to: self) {
            self = date
        }
    }

    /// SwifterSwift: Seconds.
    ///
    ///     Date().second -> 55
    ///
    ///     var someDate = Date()
    ///     someDate.second = 15 // sets someDate's seconds to 15.

    func second(_ calendar: Calendar = .current) -> Int {
        calendar.component(.second, from: self)
    }

    mutating func update(second: Int, _ calendar: Calendar = .current) {
        let allowedRange = calendar.range(of: .second, in: .minute, for: self)!
        guard allowedRange.contains(second) else { return }

        let currentSeconds = calendar.component(.second, from: self)
        let secondsToAdd = second - currentSeconds
        if let date = calendar.date(byAdding: .second, value: secondsToAdd, to: self) {
            self = date
        }
    }

    /// SwifterSwift: Check if date is in future.
    ///
    ///     Date(timeInterval: 100, since: Date()).isInFuture -> true
    ///
    var isInFuture: Bool {
        self > Date()
    }

    /// SwifterSwift: Check if date is in past.
    ///
    ///     Date(timeInterval: -100, since: Date()).isInPast -> true
    ///
    var isInPast: Bool {
        self < Date()
    }

    /// SwifterSwift: Check if date is within today.
    ///
    ///     Date().isInToday -> true
    ///
    func isInToday(_ calendar: Calendar = .current) -> Bool {
        calendar.isDateInToday(self)
    }

    /// SwifterSwift: Check if date is within yesterday.
    ///
    ///     Date().isInYesterday -> false
    ///
    func isInYesterday(_ calendar: Calendar = .current) -> Bool {
        calendar.isDateInYesterday(self)
    }

    /// SwifterSwift: Check if date is within tomorrow.
    ///
    ///     Date().isInTomorrow -> false
    ///
    func isInTomorrow(_ calendar: Calendar = .current) -> Bool {
        calendar.isDateInTomorrow(self)
    }

    /// SwifterSwift: Check if date is within a weekend period.
    func isInWeekend(_ calendar: Calendar = .current) -> Bool {
        calendar.isDateInWeekend(self)
    }

    /// SwifterSwift: Check if date is within a weekday period.
    func isWorkday(_ calendar: Calendar = .current) -> Bool {
        !calendar.isDateInWeekend(self)
    }

    /// SwifterSwift: Check if date is within the current week.
    func isInCurrentWeek(_ calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    /// SwifterSwift: Check if date is within the current month.
    func isInCurrentMonth(_ calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: Date(), toGranularity: .month)
    }

    /// SwifterSwift: Check if date is within the current year.
    func isInCurrentYear(_ calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: Date(), toGranularity: .year)
    }

    /// SwifterSwift: ISO8601 string of format (yyyy-MM-dd'T'HH:mm:ss.SSS) from date.
    ///
    ///     Date().iso8601String -> "2017-01-12T14:51:29.574Z"
    ///
    var iso8601String: String {
        // https://github.com/justinmakaila/NSDate-ISO-8601/blob/master/NSDateISO8601.swift
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"

        return dateFormatter.string(from: self).appending("Z")
    }

    /// SwifterSwift: Nearest five minutes to date.
    ///
    ///     var date = Date() // "5:54 PM"
    ///     date.minute = 32 // "5:32 PM"
    ///     date.nearestFiveMinutes // "5:30 PM"
    ///
    ///     date.minute = 44 // "5:44 PM"
    ///     date.nearestFiveMinutes // "5:45 PM"
    ///
    func nearestFiveMinutes(_ calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .nanosecond],
            from: self
        )
        let min = components.minute!
        components.minute! = min % 5 < 3 ? min - min % 5 : min + 5 - (min % 5)
        components.second = 0
        components.nanosecond = 0
        return calendar.date(from: components)!
    }

    /// SwifterSwift: Nearest ten minutes to date.
    ///
    ///     var date = Date() // "5:57 PM"
    ///     date.minute = 34 // "5:34 PM"
    ///     date.nearestTenMinutes // "5:30 PM"
    ///
    ///     date.minute = 48 // "5:48 PM"
    ///     date.nearestTenMinutes // "5:50 PM"
    ///
    func nearestTenMinutes(_ calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .nanosecond],
            from: self
        )
        let min = components.minute!
        components.minute? = min % 10 < 6 ? min - min % 10 : min + 10 - (min % 10)
        components.second = 0
        components.nanosecond = 0
        return calendar.date(from: components)!
    }

    /// SwifterSwift: Nearest quarter hour to date.
    ///
    ///     var date = Date() // "5:57 PM"
    ///     date.minute = 34 // "5:34 PM"
    ///     date.nearestQuarterHour // "5:30 PM"
    ///
    ///     date.minute = 40 // "5:40 PM"
    ///     date.nearestQuarterHour // "5:45 PM"
    ///
    func nearestQuarterHour(_ calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .nanosecond],
            from: self
        )
        let min = components.minute!
        components.minute! = min % 15 < 8 ? min - min % 15 : min + 15 - (min % 15)
        components.second = 0
        components.nanosecond = 0
        return calendar.date(from: components)!
    }

    /// SwifterSwift: Nearest half hour to date.
    ///
    ///     var date = Date() // "6:07 PM"
    ///     date.minute = 41 // "6:41 PM"
    ///     date.nearestHalfHour // "6:30 PM"
    ///
    ///     date.minute = 51 // "6:51 PM"
    ///     date.nearestHalfHour // "7:00 PM"
    ///
    func nearestHalfHour(_ calendar: Calendar = .current) -> Date {
        var components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute, .second, .nanosecond],
            from: self
        )
        let min = components.minute!
        components.minute! = min % 30 < 15 ? min - min % 30 : min + 30 - (min % 30)
        components.second = 0
        components.nanosecond = 0
        return calendar.date(from: components)!
    }

    /// SwifterSwift: Nearest hour to date.
    ///
    ///     var date = Date() // "6:17 PM"
    ///     date.nearestHour // "6:00 PM"
    ///
    ///     date.minute = 36 // "6:36 PM"
    ///     date.nearestHour // "7:00 PM"
    ///
    func nearestHour(_ calendar: Calendar = .current) -> Date {
        let min = calendar.component(.minute, from: self)
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour]
        let date = calendar.date(from: calendar.dateComponents(components, from: self))!

        if min < 30 {
            return date
        }
        return calendar.date(byAdding: .hour, value: 1, to: date)!
    }

    /// SwifterSwift: Yesterday date.
    ///
    ///     let date = Date() // "Oct 3, 2018, 10:57:11"
    ///     let yesterday = date.yesterday // "Oct 2, 2018, 10:57:11"
    ///
    func yesterday(_ calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: -1, to: self) ?? Date()
    }

    /// SwifterSwift: Tomorrow's date.
    ///
    ///     let date = Date() // "Oct 3, 2018, 10:57:11"
    ///     let tomorrow = date.tomorrow // "Oct 4, 2018, 10:57:11"
    ///
    func tomorrow(_ calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: 1, to: self) ?? Date()
    }

    /// SwifterSwift: UNIX timestamp from date.
    ///
    ///        Date().unixTimestamp -> 1484233862.826291
    ///
    var unixTimestamp: Double {
        timeIntervalSince1970
    }
}

// MARK: - Methods

public extension Date {
    /// SwifterSwift: Date by adding multiples of calendar component.
    ///
    ///     let date = Date() // "Jan 12, 2017, 7:07 PM"
    ///     let date2 = date.adding(.minute, value: -10) // "Jan 12, 2017, 6:57 PM"
    ///     let date3 = date.adding(.day, value: 4) // "Jan 16, 2017, 7:07 PM"
    ///     let date4 = date.adding(.month, value: 2) // "Mar 12, 2017, 7:07 PM"
    ///     let date5 = date.adding(.year, value: 13) // "Jan 12, 2030, 7:07 PM"
    ///
    /// - Parameters:
    ///   - component: component type.
    ///   - value: multiples of components to add.
    /// - Returns: original date + multiples of component added.
    func adding(_ component: Calendar.Component, value: Int, _ calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: component, value: value, to: self)!
    }

    /// SwifterSwift: Add calendar component to date.
    ///
    ///     var date = Date() // "Jan 12, 2017, 7:07 PM"
    ///     date.add(.minute, value: -10) // "Jan 12, 2017, 6:57 PM"
    ///     date.add(.day, value: 4) // "Jan 16, 2017, 7:07 PM"
    ///     date.add(.month, value: 2) // "Mar 12, 2017, 7:07 PM"
    ///     date.add(.year, value: 13) // "Jan 12, 2030, 7:07 PM"
    ///
    /// - Parameters:
    ///   - component: component type.
    ///   - value: multiples of component to add.
    mutating func add(_ component: Calendar.Component, value: Int, _ calendar: Calendar = .current) {
        self = adding(component, value: value, calendar)
    }

    // swiftlint:disable cyclomatic_complexity function_body_length
    /// SwifterSwift: Date by changing value of calendar component.
    ///
    ///     let date = Date() // "Jan 12, 2017, 7:07 PM"
    ///     let date2 = date.changing(.minute, value: 10) // "Jan 12, 2017, 6:10 PM"
    ///     let date3 = date.changing(.day, value: 4) // "Jan 4, 2017, 7:07 PM"
    ///     let date4 = date.changing(.month, value: 2) // "Feb 12, 2017, 7:07 PM"
    ///     let date5 = date.changing(.year, value: 2000) // "Jan 12, 2000, 7:07 PM"
    ///
    /// - Parameters:
    ///   - component: component type.
    ///   - value: new value of component to change.
    /// - Returns: original date after changing given component to given value.
    func changing(_ component: Calendar.Component, value: Int, _ calendar: Calendar = .current) -> Date? {
        switch component {
        case .nanosecond:
            #if targetEnvironment(macCatalyst)
                // The `Calendar` implementation in `macCatalyst` does not know that a nanosecond is 1/1,000,000,000th of a second
                let allowedRange = 0 ..< 1_000_000_000
            #else
                let allowedRange = calendar.range(of: .nanosecond, in: .second, for: self)!
            #endif
            guard allowedRange.contains(value) else { return nil }
            let currentNanoseconds = calendar.component(.nanosecond, from: self)
            let nanosecondsToAdd = value - currentNanoseconds
            return calendar.date(byAdding: .nanosecond, value: nanosecondsToAdd, to: self)

        case .second:
            let allowedRange = calendar.range(of: .second, in: .minute, for: self)!
            guard allowedRange.contains(value) else { return nil }
            let currentSeconds = calendar.component(.second, from: self)
            let secondsToAdd = value - currentSeconds
            return calendar.date(byAdding: .second, value: secondsToAdd, to: self)

        case .minute:
            let allowedRange = calendar.range(of: .minute, in: .hour, for: self)!
            guard allowedRange.contains(value) else { return nil }
            let currentMinutes = calendar.component(.minute, from: self)
            let minutesToAdd = value - currentMinutes
            return calendar.date(byAdding: .minute, value: minutesToAdd, to: self)

        case .hour:
            let allowedRange = calendar.range(of: .hour, in: .day, for: self)!
            guard allowedRange.contains(value) else { return nil }
            let currentHour = calendar.component(.hour, from: self)
            let hoursToAdd = value - currentHour
            return calendar.date(byAdding: .hour, value: hoursToAdd, to: self)

        case .day:
            let allowedRange = calendar.range(of: .day, in: .month, for: self)!
            guard allowedRange.contains(value) else { return nil }
            let currentDay = calendar.component(.day, from: self)
            let daysToAdd = value - currentDay
            return calendar.date(byAdding: .day, value: daysToAdd, to: self)

        case .month:
            let allowedRange = calendar.range(of: .month, in: .year, for: self)!
            guard allowedRange.contains(value) else { return nil }
            let currentMonth = calendar.component(.month, from: self)
            let monthsToAdd = value - currentMonth
            return calendar.date(byAdding: .month, value: monthsToAdd, to: self)

        case .year:
            guard value > 0 else { return nil }
            let currentYear = calendar.component(.year, from: self)
            let yearsToAdd = value - currentYear
            return calendar.date(byAdding: .year, value: yearsToAdd, to: self)

        default:
            return calendar.date(bySetting: component, value: value, of: self)
        }
    }

    #if !os(Linux)
        // swiftlint:enable cyclomatic_complexity, function_body_length

        /// SwifterSwift: Data at the beginning of calendar component.
        ///
        ///     let date = Date() // "Jan 12, 2017, 7:14 PM"
        ///     let date2 = date.beginning(of: .hour) // "Jan 12, 2017, 7:00 PM"
        ///     let date3 = date.beginning(of: .month) // "Jan 1, 2017, 12:00 AM"
        ///     let date4 = date.beginning(of: .year) // "Jan 1, 2017, 12:00 AM"
        ///
        /// - Parameter component: calendar component to get date at the beginning of.
        /// - Returns: date at the beginning of calendar component (if applicable).
        func beginning(_ calendar: Calendar = .current, of component: Calendar.Component) -> Date? {
            if component == .day {
                return calendar.startOfDay(for: self)
            }

            var components: Set<Calendar.Component> {
                switch component {
                case .second:
                    [.year, .month, .day, .hour, .minute, .second]

                case .minute:
                    [.year, .month, .day, .hour, .minute]

                case .hour:
                    [.year, .month, .day, .hour]

                case .weekOfMonth,
                     .weekOfYear:
                    [.yearForWeekOfYear, .weekOfYear]

                case .month:
                    [.year, .month]

                case .year:
                    [.year]

                default:
                    []
                }
            }

            guard !components.isEmpty else { return nil }
            return calendar.date(from: calendar.dateComponents(components, from: self))
        }
    #endif

    // swiftlint:disable function_body_length
    /// SwifterSwift: Date at the end of calendar component.
    ///
    ///     let date = Date() // "Jan 12, 2017, 7:27 PM"
    ///     let date2 = date.end(of: .day) // "Jan 12, 2017, 11:59 PM"
    ///     let date3 = date.end(of: .month) // "Jan 31, 2017, 11:59 PM"
    ///     let date4 = date.end(of: .year) // "Dec 31, 2017, 11:59 PM"
    ///
    /// - Parameter component: calendar component to get date at the end of.
    /// - Returns: date at the end of calendar component (if applicable).
    func end(_ calendar: Calendar = .current, of component: Calendar.Component) -> Date? {
        switch component {
        case .second:
            var date = adding(.second, value: 1, calendar)
            date = calendar.date(from:
                calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date))!
            date.add(.second, value: -1, calendar)
            return date

        case .minute:
            var date = adding(.minute, value: 1, calendar)
            let after = calendar.date(from:
                calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date))!
            date = after.adding(.second, value: -1, calendar)
            return date

        case .hour:
            var date = adding(.hour, value: 1, calendar)
            let after = calendar.date(from:
                calendar.dateComponents([.year, .month, .day, .hour], from: date))!
            date = after.adding(.second, value: -1, calendar)
            return date

        case .day:
            var date = adding(.day, value: 1, calendar)
            date = calendar.startOfDay(for: date)
            date.add(.second, value: -1, calendar)
            return date

        case .weekOfMonth,
             .weekOfYear:
            var date = self
            let beginningOfWeek = calendar.date(from:
                calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
            date = beginningOfWeek.adding(.day, value: 7, calendar).adding(.second, value: -1, calendar)
            return date

        case .month:
            var date = adding(.month, value: 1, calendar)
            let after = calendar.date(from:
                calendar.dateComponents([.year, .month], from: date))!
            date = after.adding(.second, value: -1, calendar)
            return date

        case .year:
            var date = adding(.year, value: 1, calendar)
            let after = calendar.date(from:
                calendar.dateComponents([.year], from: date))!
            date = after.adding(.second, value: -1, calendar)
            return date

        default:
            return nil
        }
    }

    // swiftlint:enable function_body_length

    /// SwifterSwift: Check if date is in current given calendar component.
    ///
    ///     Date().isInCurrent(.day) -> true
    ///     Date().isInCurrent(.year) -> true
    ///
    /// - Parameter component: calendar component to check.
    /// - Returns: true if date is in current given calendar component.
    func isInCurrent(_ component: Calendar.Component, _ calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: Date(), toGranularity: component)
    }

    /// SwifterSwift: Date string from date.
    ///
    ///     Date().string(withFormat: "dd/MM/yyyy") -> "1/12/17"
    ///     Date().string(withFormat: "HH:mm") -> "23:50"
    ///     Date().string(withFormat: "dd/MM/yyyy HH:mm") -> "1/12/17 23:50"
    ///
    /// - Parameter format: Date format (default is "dd/MM/yyyy").
    /// - Returns: date string.
    func string(withFormat format: String = "dd/MM/yyyy HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    /// SwifterSwift: Date string from date.
    ///
    ///     Date().dateString(ofStyle: .short) -> "1/12/17"
    ///     Date().dateString(ofStyle: .medium) -> "Jan 12, 2017"
    ///     Date().dateString(ofStyle: .long) -> "January 12, 2017"
    ///     Date().dateString(ofStyle: .full) -> "Thursday, January 12, 2017"
    ///
    /// - Parameter style: DateFormatter style (default is .medium).
    /// - Returns: date string.
    func dateString(ofStyle style: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }

    /// SwifterSwift: Date and time string from date.
    ///
    ///     Date().dateTimeString(ofStyle: .short) -> "1/12/17, 7:32 PM"
    ///     Date().dateTimeString(ofStyle: .medium) -> "Jan 12, 2017, 7:32:00 PM"
    ///     Date().dateTimeString(ofStyle: .long) -> "January 12, 2017 at 7:32:00 PM GMT+3"
    ///     Date().dateTimeString(ofStyle: .full) -> "Thursday, January 12, 2017 at 7:32:00 PM GMT+03:00"
    ///
    /// - Parameter style: DateFormatter style (default is .medium).
    /// - Returns: date and time string.
    func dateTimeString(ofStyle style: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = style
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }

    /// SwifterSwift: Time string from date.
    ///
    ///     Date().timeString(ofStyle: .short) -> "7:37 PM"
    ///     Date().timeString(ofStyle: .medium) -> "7:37:02 PM"
    ///     Date().timeString(ofStyle: .long) -> "7:37:02 PM GMT+3"
    ///     Date().timeString(ofStyle: .full) -> "7:37:02 PM GMT+03:00"
    ///
    /// - Parameter style: DateFormatter style (default is .medium).
    /// - Returns: time string.
    func timeString(ofStyle style: DateFormatter.Style = .medium) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = style
        dateFormatter.dateStyle = .none
        return dateFormatter.string(from: self)
    }

    /// SwifterSwift: Day name from date.
    ///
    ///     Date().dayName(ofStyle: .oneLetter) -> "T"
    ///     Date().dayName(ofStyle: .threeLetters) -> "Thu"
    ///     Date().dayName(ofStyle: .full) -> "Thursday"
    ///
    /// - Parameter Style: style of day name (default is DayNameStyle.full).
    /// - Returns: day name string (example: W, Wed, Wednesday).
    func dayName(ofStyle style: DayNameStyle = .full) -> String {
        // http://www.codingexplorer.com/swiftly-getting-human-readable-date-nsdateformatter/
        let dateFormatter = DateFormatter()
        var format: String {
            switch style {
            case .oneLetter:
                "EEEEE"
            case .threeLetters:
                "EEE"
            case .full:
                "EEEE"
            }
        }
        dateFormatter.setLocalizedDateFormatFromTemplate(format)
        return dateFormatter.string(from: self)
    }

    /// SwifterSwift: Month name from date.
    ///
    ///     Date().monthName(ofStyle: .oneLetter) -> "J"
    ///     Date().monthName(ofStyle: .threeLetters) -> "Jan"
    ///     Date().monthName(ofStyle: .full) -> "January"
    ///
    /// - Parameter Style: style of month name (default is MonthNameStyle.full).
    /// - Returns: month name string (example: D, Dec, December).
    func monthName(ofStyle style: MonthNameStyle = .full) -> String {
        // http://www.codingexplorer.com/swiftly-getting-human-readable-date-nsdateformatter/
        let dateFormatter = DateFormatter()
        var format: String {
            switch style {
            case .oneLetter:
                "MMMMM"
            case .threeLetters:
                "MMM"
            case .full:
                "MMMM"
            }
        }
        dateFormatter.setLocalizedDateFormatFromTemplate(format)
        return dateFormatter.string(from: self)
    }

    /// SwifterSwift: get number of seconds between two date
    ///
    /// - Parameter date: date to compare self to.
    /// - Returns: number of seconds between self and given date.
    func secondsSince(_ date: Date) -> Double {
        timeIntervalSince(date)
    }

    /// SwifterSwift: get number of minutes between two date
    ///
    /// - Parameter date: date to compare self to.
    /// - Returns: number of minutes between self and given date.
    func minutesSince(_ date: Date) -> Double {
        timeIntervalSince(date) / 60
    }

    /// SwifterSwift: get number of hours between two date
    ///
    /// - Parameter date: date to compare self to.
    /// - Returns: number of hours between self and given date.
    func hoursSince(_ date: Date) -> Double {
        timeIntervalSince(date) / 3600
    }

    /// SwifterSwift: get number of days between two date
    ///
    /// - Parameter date: date to compare self to.
    /// - Returns: number of days between self and given date.
    func daysSince(_ date: Date) -> Double {
        timeIntervalSince(date) / (3600 * 24)
    }

    /// SwifterSwift: check if a date is between two other dates.
    ///
    /// - Parameters:
    ///   - startDate: start date to compare self to.
    ///   - endDate: endDate date to compare self to.
    ///   - includeBounds: true if the start and end date should be included (default is false).
    /// - Returns: true if the date is between the two given dates.
    func isBetween(_ startDate: Date, _ endDate: Date, includeBounds: Bool = false) -> Bool {
        if includeBounds {
            return startDate.compare(self).rawValue * compare(endDate).rawValue >= 0
        }
        return startDate.compare(self).rawValue * compare(endDate).rawValue > 0
    }

    /// SwifterSwift: check if a date is a number of date components of another date.
    ///
    /// - Parameters:
    ///   - value: number of times component is used in creating range.
    ///   - component: Calendar.Component to use.
    ///   - date: Date to compare self to.
    /// - Returns: true if the date is within a number of components of another date.
    func isWithin(_ value: UInt, _ calendar: Calendar = .current, _ component: Calendar.Component, of date: Date) -> Bool {
        let components = calendar.dateComponents([component], from: self, to: date)
        let componentValue = components.value(for: component)!
        return abs(componentValue) <= value
    }

    /// SwifterSwift: Returns a random date within the specified range.
    ///
    /// - Parameter range: The range in which to create a random date. `range` must not be empty.
    /// - Returns: A random date within the bounds of `range`.
    static func random(in range: Range<Date>) -> Date {
        Date(timeIntervalSinceReferenceDate:
            TimeInterval
                .random(in: range.lowerBound.timeIntervalSinceReferenceDate ..< range.upperBound
                    .timeIntervalSinceReferenceDate))
    }

    /// SwifterSwift: Returns a random date within the specified range.
    ///
    /// - Parameter range: The range in which to create a random date.
    /// - Returns: A random date within the bounds of `range`.
    static func random(in range: ClosedRange<Date>) -> Date {
        Date(timeIntervalSinceReferenceDate:
            TimeInterval
                .random(in: range.lowerBound.timeIntervalSinceReferenceDate ... range.upperBound
                    .timeIntervalSinceReferenceDate))
    }

    /// SwifterSwift: Returns a random date within the specified range, using the given generator as a source for randomness.
    ///
    /// - Parameters:
    ///   - range: The range in which to create a random date. `range` must not be empty.
    ///   - generator: The random number generator to use when creating the new random date.
    /// - Returns: A random date within the bounds of `range`.
    static func random(in range: Range<Date>, using generator: inout some RandomNumberGenerator) -> Date {
        Date(timeIntervalSinceReferenceDate:
            TimeInterval.random(
                in: range.lowerBound.timeIntervalSinceReferenceDate ..< range.upperBound.timeIntervalSinceReferenceDate,
                using: &generator
            ))
    }

    /// SwifterSwift: Returns a random date within the specified range, using the given generator as a source for randomness.
    ///
    /// - Parameters:
    ///   - range: The range in which to create a random date.
    ///   - generator: The random number generator to use when creating the new random date.
    /// - Returns: A random date within the bounds of `range`.
    static func random(in range: ClosedRange<Date>, using generator: inout some RandomNumberGenerator) -> Date {
        Date(timeIntervalSinceReferenceDate:
            TimeInterval.random(
                in: range.lowerBound.timeIntervalSinceReferenceDate ... range.upperBound.timeIntervalSinceReferenceDate,
                using: &generator
            ))
    }
}

// MARK: - Initializers

public extension Date {
    /// SwifterSwift: Create date object from ISO8601 string.
    ///
    ///     let date = Date(iso8601String: "2017-01-12T16:48:00.959Z") // "Jan 12, 2017, 7:48 PM"
    ///
    /// - Parameter iso8601String: ISO8601 string of format (yyyy-MM-dd'T'HH:mm:ss.SSSZ).
    init?(iso8601String: String) {
        // https://github.com/justinmakaila/NSDate-ISO-8601/blob/master/NSDateISO8601.swift
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let date = dateFormatter.date(from: iso8601String) else { return nil }
        self = date
    }

    /// SwifterSwift: Create new date object from UNIX timestamp.
    ///
    ///     let date = Date(unixTimestamp: 1484239783.922743) // "Jan 12, 2017, 7:49 PM"
    ///
    /// - Parameter unixTimestamp: UNIX timestamp.
    init(unixTimestamp: Double) {
        self.init(timeIntervalSince1970: unixTimestamp)
    }

    /// SwifterSwift: Create date object from Int literal.
    ///
    ///     let date = Date(integerLiteral: 2017_12_25) // "2017-12-25 00:00:00 +0000"
    /// - Parameter value: Int value, e.g. 20171225, or 2017_12_25 etc.
    init?(integerLiteral value: Int) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        guard let date = formatter.date(from: String(value)) else { return nil }
        self = date
    }
}

public extension Date {
    func isThisYear(calendar: Calendar = .current) -> Bool {
        let currentYear = calendar.component(.year, from: Date())
        return calendar.component(.year, from: self) == currentYear
    }

    func isSameDay(_ date: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, inSameDayAs: date)
    }
}
