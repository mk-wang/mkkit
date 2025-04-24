//
//  GCCalendarViewDelegate.swift
//  GCCalendar
//
//  Created by Gray Campbell on 3/4/17.
//

import UIKit

// MARK: - GCCalendarViewDelegate

/// The delegate of a GCCalendarView object must adopt the GCCalendarViewDelegate protocol. The protocol's optional methods allow the delegate to handle date selection and customize the calendar view's appearance.

public protocol GCCalendarViewDelegate: AnyObject {
    // MARK: Date Selection

    /// Tells the delegate that the calendar view selected a new date in the specified calendar.
    ///
    /// - Parameter calendarView: The calendar view.
    /// - Parameter date: The selected date.
    func calendarView(_ calendarView: GCCalendarView, didSelectDate date: Date, previousDate: Date?)

    func calendarView(_ calendarView: GCCalendarView, showDateView: GCCalendarDateView)
}

public extension GCCalendarViewDelegate {
    func calendarView(_: GCCalendarView, didSelectDate _: Date, previousDate _: Date?) {}
    func calendarView(_: GCCalendarView, showDateView _: GCCalendarDateView) {}
}
