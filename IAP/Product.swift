//
//  Product.swift
//  MKKit
//
//  Created by MK on 2023/9/27.
//

import Foundation
import MKKit
import OpenCombine
import SwiftyStoreKit

// MARK: - IAPService1.Config

public extension MKIAPService {
    struct Product: Equatable {
        public let id: String
        public let isAutoRenewable: Bool
        public let isSubscription: Bool

        public static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.id == rhs.id
        }

        public init(id: String,
                    isAutoRenewable: Bool,
                    isSubscription: Bool,
                    originPriceBuilder _: ((SKProduct) -> String?)? = nil)
        {
            self.id = id
            self.isAutoRenewable = isAutoRenewable
            self.isSubscription = isSubscription
        }
    }

    struct Price: Equatable, Codable {
        public let price: String
        public let origin: String?
        public let trail: Int?

        public init(price: String, origin: String? = nil, trail: Int? = nil) {
            self.price = price
            self.origin = origin
            self.trail = trail
        }

        public static var `default`: Self {
            .init(price: "")
        }
    }

    open class ProductInfo: Equatable {
        public let product: Product
        private let priceSubject: CurrentValueSubject<Price, Never>
        public let originPriceBuilder: ((SKProduct) -> String?)?

        public lazy var pricePublisher = priceSubject.eraseToAnyPublisher()
        public var price: Price {
            priceSubject.value
        }

        public var skProduct: SKProduct? {
            didSet {
                if let skProduct {
                    let price = skProduct.localizedPrice ?? ""
                    var origin: String? = nil
                    if let originPriceBuilder {
                        origin = originPriceBuilder(skProduct)
                    }
                    let trail: Int? = skProduct.introductoryPrice?.subscriptionPeriod.numberOfUnits
                    priceSubject.value = Price(price: price, origin: origin, trail: trail)
                }
            }
        }

        public init(product: Product,
                    priceSubject: CurrentValueSubject<Price, Never>,
                    originPriceBuilder: ((SKProduct) -> String?)?,
                    skProduct: SKProduct?)
        {
            // to use didSet
            defer {
                self.skProduct = skProduct
            }
            self.originPriceBuilder = originPriceBuilder
            self.product = product
            self.priceSubject = priceSubject
        }

        public static func == (lhs: ProductInfo, rhs: ProductInfo) -> Bool {
            lhs.product == rhs.product
        }
    }
}

// MARK: - MKIAPService.Price + KVStorageSerializable

extension MKIAPService.Price: KVStorageSerializable {
    public static func write(storage: MKKit.KVStorage, value: KVValue, key: String) {
        storage.set(value, for: key)
    }

    public static func read(storage: KVStorage, key: String) -> KVValue? {
        storage.string(for: key)
    }

    public var kvValue: String {
        jsonString!
    }

    public init(kvValue: String) {
        let value = kvValue.decodeJson(defalut: Self.default)
        price = value.price
        origin = value.origin
        trail = value.trail
    }

    public typealias KVValue = String
}
