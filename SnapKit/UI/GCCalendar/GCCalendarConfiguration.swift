//
//  GCCalendarConfiguration.swift
//  GCCalendar
//
//  Created by Gray Campbell on 3/6/17.
//

import UIKit

// MARK: - GCCalendarConfiguration

public class GCCalendarConfiguration {
    public enum GCCalendarDisplayMode {
        /// The calendar is displayed one week at a time.

        case week

        /// The calendar is displayed one month at a time.

        case month
    }

    // MARK: Header

    public struct HeaderConfig {
        public var height: CGFloat
        public var bottomMargin: CGFloat
        public var viewConfig: (GCCalendarView, UILabel, Int) -> Void

        public init(height: CGFloat,
                    bottomMargin: CGFloat,
                    viewConfig: @escaping (GCCalendarView, UILabel, Int) -> Void)
        {
            self.height = height
            self.bottomMargin = bottomMargin
            self.viewConfig = viewConfig
        }
    }

    public struct WeekConfig {
        var height: CGFloat
        var selectByWeek: Bool
        var viewBuilder: ((GCCalendarConfiguration) -> GCCalendarWeekView)?

        public init(height: CGFloat,
                    selectByWeek: Bool,
                    viewBuilder: ((GCCalendarConfiguration) -> GCCalendarWeekView)? = nil)
        {
            self.height = height
            self.selectByWeek = selectByWeek
            self.viewBuilder = viewBuilder
        }
    }

    public struct DayConfig {
        var viewBuilder: ((GCCalendarConfiguration) -> GCCalendarDayView)?
        var viewConfig: ((GCCalendarDayView) -> Void)?

        public init(viewBuilder: ((GCCalendarConfiguration) -> GCCalendarDayView)? = nil,
                    viewConfig: ((GCCalendarDayView) -> Void)? = nil)
        {
            self.viewBuilder = viewBuilder
            self.viewConfig = viewConfig
        }
    }

    // MARK: Calendar

    let calendar: Calendar
    let displayMode: GCCalendarDisplayMode
    let numberOfWeekdays: Int

    public init(calendar: Calendar, displayMode: GCCalendarDisplayMode = .month) {
        self.calendar = calendar
        self.displayMode = displayMode
        numberOfWeekdays = calendar.numberOfWeekdays
    }

    public var weekdayBuilder: ((GCCalendarConfiguration, Int) -> String?)? = {
        $0.calendar.shortStandaloneWeekdaySymbols[$1 - 1]
    }

    public var headerConfig: HeaderConfig? = .init(height: 15,
                                                   bottomMargin: 0)
    { calendarView, lable, weekday in
        let configuration = calendarView.configuration
        let text = configuration.weekdayBuilder?(configuration, weekday)
        lable.textAlignment = .center
        lable.font = .systemFont(ofSize: 16)
        lable.textColor = .gray
        lable.text = text
    }

    public var enablePanGesture: Bool = true

    public var weekConfig: WeekConfig = .init(height: 45,
                                              selectByWeek: false,
                                              viewBuilder: nil)

    public var dayConfig: DayConfig = .init(viewBuilder: {
        GCCalendarDayView.SimpleDayView(frame: .zero, configuration: $0)
    })

    public var pastDatesEnabled: Bool = true
    public var canSelectFuture: Bool = true
    public var itemSpacing: CGFloat = 10
    public var weekSpacing: CGFloat = 10
    public var xPad: CGFloat = 0

    public var maxDate: (() -> Date?)?
    public var minDate: (() -> Date?)?
}

extension GCCalendarConfiguration {
    var maxWeekOfMonth: Int { 6 }

    public var calendarHeight: CGFloat {
        var height: CGFloat = weekConfig.height
        if let headerConfig {
            height += headerConfig.height + headerConfig.bottomMargin
        }
        if displayMode == .month {
            height += CGFloat(maxWeekOfMonth - 1) * (weekConfig.height + weekSpacing)
        }
        return height
    }

    func isToday(date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: .init())
    }
}

extension GCCalendarConfiguration {
    func weekday(of index: Int) -> Int {
        let day = index + calendar.firstWeekdayIndex
        return (day % numberOfWeekdays) + 1
    }

    // the beginning of everryday
    func weekDates(startDate: Date) -> [Date?] {
        var dateComponents = calendar.dateComponents([.weekOfYear, .year], from: startDate)

        return (0 ..< numberOfWeekdays).map { [unowned(unsafe) self] in
            dateComponents.weekday = weekday(of: $0)
            return calendar.date(from: dateComponents)
        }
    }
}
