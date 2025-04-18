//
//  TimeService.swift
//
//  Created by MK on 2021/7/30.
//

import Foundation
import UIKit

// MARK: - Day

public struct Day {
    public let calendar: Calendar
    public let year: Int
    public let month: Int
    public let day: Int

    fileprivate init(calendar: Calendar, year: Int, month: Int, day: Int) {
        self.calendar = calendar
        self.year = year
        self.month = month
        self.day = day
    }

    public init(date: Date, calendar: Calendar = .current) {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(calendar: calendar, year: comps.year!, month: comps.month!, day: comps.day!)
    }
}

// MARK: Equatable

extension Day: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.calendar.timeZone.identifier == rhs.calendar.timeZone.identifier
            && lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
}

extension Day {
    var date: Date? {
        var comps = DateComponents()
        comps.day = day
        comps.year = year
        comps.month = month
        return calendar.date(from: comps)
    }
}

// MARK: - Hour

public struct Hour {
    public let day: Day
    public let hour: Int

    public init(day: Day, hour: Int) {
        self.day = day
        self.hour = hour
    }

    public init(date: Date, calendar: Calendar = .current) {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        day = .init(calendar: calendar, year: comps.year!, month: comps.month!, day: comps.day!)
        hour = comps.hour!
    }
}

// MARK: Equatable

extension Hour: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hour == rhs.hour && lhs.day == rhs.day
    }
}

// MARK: - DayTime

public enum DayTime: Int {
    case morning = 5
    case afternoon = 12
    case evening = 17
}

// MARK: Equatable

extension DayTime: Equatable {}

public extension Hour {
    var dayTime: DayTime {
        if hour >= DayTime.evening.rawValue {
            .evening
        } else if hour >= DayTime.afternoon.rawValue {
            .afternoon
        } else if hour >= DayTime.morning.rawValue {
            .morning
        } else {
            .evening
        }
    }
}

// MARK: - TimeService

public class TimeService {
    private let hourSubject: CurrentValueSubjectType<Hour, Never>

    public lazy var hourPublisher = hourSubject.eraseToAnyPublisher()
    public lazy var dayPublisher = hourSubject.map(\.day).receiveOnMain().eraseToAnyPublisher()
    public lazy var dayTimePublisher = hourSubject.map(\.dayTime).removeDuplicates().receiveOnMain().eraseToAnyPublisher()

    private var LastHour: Int64 = 0
    private var lastMinute: Int64 = 0

    private var timer: SwiftTimer?
    private var dayChangeObs: AnyCancellableType?
    private var appStateObs: AnyCancellableType?

    public init() {
        let now = Date()
        hourSubject = .init(.init(date: now))

        dayChangeObs = notificationCenter
            .publisher(for: .NSCalendarDayChanged)
            .sink { [weak self] _ in
                self?.checkTime()
            }

        appStateObs = MKAppDelegate.shared?.isActivePublisher
            .sink { [weak self] in
                if $0 {
                    self?.startTimeCheck()
                } else {
                    self?.stopTimeCheck()
                }
            }
        startTimeCheck()
    }
}

public extension TimeService {
    var hour: Hour {
        hourSubject.value
    }

    func startTimeCheck() {
        checkTime()

        // 每小时变更
        let interval = 3600
        let seconds = Int64(Date.timeIntervalSinceReferenceDate)
        var delay = interval - Int(seconds % Int64(interval))
        if delay == interval {
            delay = 0
        }

        timer = SwiftTimer(interval: .seconds(interval),
                           delay: .seconds(delay),
                           repeats: true,
                           handler: { [weak self] _ in
                               self?.checkTime()
                           })
        timer?.start()
    }

    func stopTimeCheck() {
        timer = nil
    }

    private func checkTime() {
        let hour = Hour(date: .init())
        if hour != hourSubject.value {
            hourSubject.value = hour
        }
    }
}
