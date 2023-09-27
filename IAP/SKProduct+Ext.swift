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

    func originPrice(rate: NSDecimalNumber) -> String? {
        let formatter = NumberFormatter()
        formatter.locale = priceLocale
        formatter.numberStyle = .currency
        let value = price.dividing(by: rate)
        return formatter.string(from: value)
    }
}
