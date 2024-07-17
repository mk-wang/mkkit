//
//  TimeZoneExt.swift
//  MKKit
//
//  Created by MK on 2024/7/17.
//

import Foundation

public extension TimeZone {
    var isUserTimeZoneInUSA: Bool {
        identifier.starts(with: "US/") || Self.usTimeZones.contains(identifier)
    }

    static let usTimeZones = [
        // Mainland U.S. Time Zones
        "America/Adak", // Aleutian Islands, Alaska
        "America/Anchorage", // Alaska
        "America/Boise", // Idaho
        "America/Chicago", // Central Time Zone
        "America/Denver", // Mountain Time Zone
        "America/Detroit", // Eastern Time Zone
        "America/Indiana/Indianapolis",
        "America/Indiana/Knox",
        "America/Indiana/Marengo",
        "America/Indiana/Petersburg",
        "America/Indiana/Tell_City",
        "America/Indiana/Vevay",
        "America/Indiana/Vincennes",
        "America/Indiana/Winamac",
        "America/Juneau", // Alaska
        "America/Kentucky/Louisville",
        "America/Kentucky/Monticello",
        "America/Los_Angeles", // Pacific Time Zone
        "America/Menominee", // Michigan
        "America/Metlakatla", // Alaska
        "America/New_York", // Eastern Time Zone
        "America/Nome", // Alaska
        "America/North_Dakota/Beulah",
        "America/North_Dakota/Center",
        "America/North_Dakota/New_Salem",
        "America/Phoenix", // Arizona
        "America/Sitka", // Alaska
        "America/Yakutat", // Alaska

        // U.S. Territories in the Pacific
        "Pacific/Honolulu", // Hawaii
        "Pacific/Guam", // Guam
        "Pacific/Saipan", // Northern Mariana Islands
        "Pacific/Wake", // Wake Island
        "Pacific/Johnston", // Johnston Atoll
        "Pacific/Midway", // Midway Islands
        "Pacific/Pago_Pago", // American Samoa
    ]
}
