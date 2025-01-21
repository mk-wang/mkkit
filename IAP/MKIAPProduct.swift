//
//  MKIAPProduct.swift
//  MKKit
//
//  Created by MK on 2023/9/27.
//

import Foundation
#if canImport(OpenCombine)
    import OpenCombine
#elseif canImport(Combine)
    import Combine
#endif
import SwiftyStoreKit

// MARK: - MKIAPProductSimple

public protocol MKIAPProductSimple {
    var id: String {
        get
    }

    var isAutoRenewable: Bool {
        get
    }

    var isSubscription: Bool {
        get
    }
}

// MARK: - MKIAPProduct

public protocol MKIAPProduct: MKIAPProductSimple {
    func update(skProduct: SKProduct)
}
