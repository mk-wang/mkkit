//
//  GCCalendarDateView.swift
//
//  Created by MK on 2023/11/13.
//

import Foundation
import UIKit

// MARK: - GCCalendarDateView

public protocol GCCalendarDateView: UIView {
    var begin: Date? {
        get
    }

    var nextBegin: Date? {
        get
    }

    var prevBegin: Date? {
        get
    }
}

// MARK: - GCCalendarWeekView + GCCalendarDateView

extension GCCalendarWeekView: GCCalendarDateView {
    public var begin: Date? {
        dates.first ?? nil
    }

    public var nextBegin: Date? {
        begin?.adding(.day, value: configuration.numberOfWeekdays)
    }

    public var prevBegin: Date? {
        begin?.adding(.day, value: -configuration.numberOfWeekdays)
    }
}

// MARK: - GCCalendarMonthView + GCCalendarDateView

extension GCCalendarMonthView: GCCalendarDateView {
    public var begin: Date? {
        startDate
    }

    public var nextBegin: Date? {
        startDate?.adding(.month, value: 1)
    }

    public var prevBegin: Date? {
        startDate?.adding(.month, value: -1)
    }
}
