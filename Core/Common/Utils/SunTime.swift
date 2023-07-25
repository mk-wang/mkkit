//
//  SunTime.swift
//  MKKit
//
//  Created by MK on 2023/7/23.
//

import CoreLocation
import Foundation

// MARK: - SunTime

public enum SunTime {}

// MARK: SunTime.LocationCoord

public extension SunTime {
    static func sunrise(location: CLLocationCoordinate2D,
                        calendar: Calendar,
                        date: Date) -> Date?
    {
        getTime(sunrise: true, location: location, calendar: calendar, date: date)
    }

    static func sunset(location: CLLocationCoordinate2D,
                       calendar: Calendar,
                       date: Date) -> Date?
    {
        getTime(sunrise: false, location: location, calendar: calendar, date: date)
    }
}

private extension SunTime {
    static let zenithFactor = cos((2180.decimalNumber / 24.decimalNumber).angle.doubleValue).decimalNumber

    static func getTime(sunrise: Bool,
                        location: CLLocationCoordinate2D,
                        calendar: Calendar,
                        date: Date) -> Date?
    {
        guard let number = getValue(sunrise: sunrise,
                                    location: location,
                                    calendar: calendar,
                                    date: date)
        else {
            return nil
        }
        return parseTime(number: number, calendar: calendar, date: date)
    }

    static func getValue(sunrise: Bool,
                         location: CLLocationCoordinate2D,
                         calendar: Calendar, date: Date) -> NSDecimalNumber?
    {
        let latDecimal = location.latitude.decimalNumber
        let longDecimal = location.longitude.decimalNumber
        let latAngle = latDecimal.angle

        let day = calendar.ordinality(of: .day, in: .year, for: date)!
        var t1 = (sunrise ? 6 : 18).decimalNumber
        t1 -= longDecimal / 15
        t1 /= 24
        let k11 = t1 + day.decimalNumber
        let k12 = 0.9856.decimalNumber * k11 - 3.289.decimalNumber
        let k12Angle = k12.angle.doubleValue
        t1 = sin(k12Angle).decimalNumber * 1.916
        var t2 = sin(k12Angle * 2).decimalNumber * 0.020 + 282.634
        var add = t1 + t2 + k12
        if add > 360 {
            add -= 360
        }
        let k13Angle = add.angle
        let k14 = (sin(k13Angle.doubleValue) * 0.39782).decimalNumber

        t2 = zenithFactor - k14 * (sin(latAngle.doubleValue).decimalNumber)
        t1 = cos(asin(k14.doubleValue)).decimalNumber
        t1 *= cos(latAngle.doubleValue).decimalNumber

        let k15 = t2 / t1
        if k15.abs.doubleValue > 1 {
            return nil
        }

        var f11 = acos(k15.doubleValue).decimalNumber.radian
        if sunrise {
            f11 = 360 - f11
        }
        let g = f11 / 15

        t1 = (tan(k13Angle.doubleValue).decimalNumber.radian * 0.91764).angle
        var k16 = atan(t1.doubleValue).decimalNumber.radian
        if k16 < 0 {
            k16 += 360
        } else if k16 > 360 {
            k16 -= 360
        }
        let rectAngle: Double = 90
        t1 = (floor(k16.doubleValue / rectAngle) * rectAngle).decimalNumber
        t2 = (floor(add.doubleValue / rectAngle) * rectAngle).decimalNumber
        t1 = t2 - t1
        t2 = k16 + t1
        t1 = t2 / 15
        var subtract = g + t1 - k11 * 0.06571 - 6.622

        if subtract < 0 {
            subtract += 24
        } else if subtract > 24 {
            subtract -= 24
        }
        t1 = longDecimal / 15

        let timezone = calendar.timeZone
        let offset = Double(timezone.secondsFromGMT())
        t2 = (offset / 3600.0).decimalNumber
        t2 = NSDecimalNumber.RoundingMode.plain.round(value: t2, scale: 2)
        var value = subtract - t1 + t2

        if timezone.isDaylightSavingTime(for: date) {
            value += 1
        }
        if value > 24 {
            value -= 24
        }

        return value
    }

    static func parseTime(number: NSDecimalNumber, calendar: Calendar, date: Date) -> Date? {
        var time = number.doubleValue
        var lastDay = false

        if time < 0 {
            time += 24
            lastDay = true
        }

        let hour = floor(time)
        var hourInt = Int(hour)

        let minute = (time - hour) * 60
        let minuteDecimal = NSDecimalNumber.RoundingMode.bankers.round(value: minute.decimalNumber, scale: 0)
        var minuteInt = minuteDecimal.intValue

        if minuteInt >= 60 {
            minuteInt = 0
            hourInt += 1
        }
        if hourInt >= 24 {
            hourInt = 0
        }

        guard var rt = calendar.date(bySettingHour: hourInt,
                                     minute: minuteInt,
                                     second: 0,
                                     of: date)
        else {
            return nil
        }

        if lastDay {
            rt = .init(timeIntervalSince1970: rt.timeIntervalSince1970 - 24 * 60 * 60)
        }
        return rt
    }
}
