//
//  SKProduct+Ext.swift
//  MKKit
//
//  Created by MK on 2023/9/27.
//

import Foundation
import StoreKit

public extension SKProduct {
    var currency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.currencyCode
    }

    func localizedRatePrice(rate: NSDecimalNumber) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = priceLocale
        formatter.numberStyle = .currency
        let value = price * rate
        return formatter.string(from: value)
    }

    // 保留整数，把小数点后面都转为9
    func fixedLocalizedRatePrice(rate: NSDecimalNumber) -> String? {
        guard var str = localizedRatePrice(rate: rate) else {
            return nil
        }

        var list = str.split(separator: ".")
        if let last = list.last {
            let converted = last.replacingOccurrences(of: "[0-9]", with: "9", options: .regularExpression)
            list[list.count - 1] = Substring(converted)
            str = list.joined(separator: ".")
        }

        return str
    }
}
