//
//  MKIAPProduct.swift
//  MKKit
//
//  Created by MK on 2023/9/27.
//

import Foundation
import MKKit
import OpenCombine
import SwiftyStoreKit

// MARK: - MKIAPProduct

public protocol MKIAPProduct {
    var id: String {
        get
    }
    var isAutoRenewable: Bool {
        get
    }
    var isSubscription: Bool {
        get
    }

    func update(skProduct: SKProduct)
}
