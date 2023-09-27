//
//  MKIAPService.swift
//  MKKit
//
//  Created by MK on 2023/9/27.
//

import Foundation
import MKKit
import OpenCombine
import SwiftyStoreKit

// MARK: - MKIAPService.Config

public extension MKIAPService {
    struct Config {
        public let setPremiumAtLaunch: Bool
        public let failAtLaunch: Bool
        public let passbyLocalVerification: Bool
        public let envBuilder: ValueBuilder<IAPEnvironment>?

        public init(setPremiumAtLaunch: Bool,
                    failAtLaunch: Bool,
                    passbyLocalVerification: Bool = false,
                    envBuilder: ValueBuilder<IAPEnvironment>? = nil)
        {
            self.setPremiumAtLaunch = setPremiumAtLaunch
            self.passbyLocalVerification = passbyLocalVerification
            self.failAtLaunch = failAtLaunch
            self.envBuilder = envBuilder
        }
    }
}

// MARK: - MKIAPService

open class MKIAPService {
    public let sharedSecret: String
    public var purchasedSubject: CurrentValueSubject<Set<String>, Never>

    open var purchased: Set<String> {
        get {
            purchasedSubject.value
        }
        set {
            if purchasedSubject.value != newValue {
                purchasedSubject.value = newValue
            }
        }
    }

    public let productList: [MKIAPProduct]

    public let config: Config

    private var loadingProduct: Bool = false

    private let premiumSubject = CurrentValueSubject<Bool, Never>(false)
    public lazy var premiumPublisher = premiumSubject.eraseToAnyPublisher()

    open var isPremium: Bool {
        get {
            premiumSubject.value
        }
        set {
            premiumSubject.value = newValue
        }
    }

    public init(sharedSecret: String,
                purchasedSubject: CurrentValueSubject<Set<String>, Never>,
                productList: [MKIAPProduct],
                config: Config)
    {
        self.sharedSecret = sharedSecret
        self.productList = productList
        self.purchasedSubject = purchasedSubject
        self.config = config
    }

    public lazy var productIDList = productList.map(\.id)
}

extension MKIAPService {
    public func purchase(product: MKIAPProduct, callback: ((Bool) -> Void)? = nil) {
        let productID = product.id
        IAPHelper.purchase(productID: productID,
                           secret: sharedSecret,
                           environment: iapEnv,
                           subscription: product.isSubscription)
        { [weak self] suc, error in
            Logger.shared.iap("purchase \(productID) \(suc) error \(error?.localizedDescription ?? "")")

            if suc {
                self?.didPurchase([productID], override: false, setPremium: true)
            }
            if let callback {
                callback(suc)
            }
        }
    }

    public func checkAtAppStart() {
        Logger.shared.iap("checkAtAppStart purchased  \(purchased) ")

        isPremium = purchased.isNotEmpty
        let setPremium = config.setPremiumAtLaunch

        IAPHelper.startObserving { [weak self] result in
            Logger.shared.iap("checkAtAppStart observing  \(result.purchased) ")
            if !result.purchased.isEmpty {
                self?.validatePurchase(setPremium: setPremium, forceRefresh: false)
            }
        }

        if isPremium {
            validatePurchase(setPremium: config.failAtLaunch, forceRefresh: false)
        }

        loadProducts()
    }

    public func restorePurchase(setPremium: Bool, callback: ((Bool) -> Void)? = nil) {
        IAPHelper.restore { [weak self] results in
            let suc = results.restoredPurchases.isNotEmpty
            Logger.shared.iap("restorePurchase \(suc) ")

            if suc {
                self?.validatePurchase(setPremium: setPremium, forceRefresh: true, callback: callback)
            } else {
                callback?(suc)
            }
        }
    }

    public func loadProducts() {
        guard !loadingProduct else {
            return
        }

        loadingProduct = true
        IAPHelper.getList(productList: productIDList) { [weak self] results in
            Logger.shared.iap("loadProducts get \(results.retrievedProducts.map(\.productIdentifier)) ")

            for result in results.retrievedProducts {
                self?.updateSKProduct(skProduct: result)
            }
            self?.loadingProduct = false
        }
    }

    func updateSKProduct(skProduct: SKProduct) {
        productList.first {
            $0.id == skProduct.productIdentifier
        }?.update(skProduct: skProduct)
    }

    func validatePurchase(setPremium: Bool, forceRefresh: Bool, callback: ((Bool) -> Void)? = nil) {
        let environment = iapEnv
        var products = [String]()
        var subscriptions = [String]()

        for product in productList {
            if !product.isSubscription {
                products.append(product.id)
            } else if product.isAutoRenewable {
                subscriptions.append(product.id)
            } // TODO: handle not isAutoRenewable
        }

        Logger.shared.iap("validatePurchase setPremium \(setPremium), forceRefresh \(forceRefresh)")

        let passbyLocalVerification = config.passbyLocalVerification

        IAPHelper.verifyPurchase(products: products,
                                 subscriptions: subscriptions,
                                 secret: sharedSecret,
                                 forceRefresh: forceRefresh,
                                 environment: environment)
        { [weak self] result, error in
            var idSet: Set<String>?

            defer {
                if let idSet {
                    self?.didPurchase(idSet, override: true, setPremium: setPremium)
                    callback?(true)
                } else {
                    self?.resetPurchase(setPremium: setPremium)
                    callback?(false)
                }
            }

            guard environment != .local else {
                #if DEBUG_BUILD
                    if passbyLocalVerification {
                        idSet = Set(products).union(subscriptions)
                    }
                #endif
                return
            }

            if error == nil, let purchased = result?.purchased, purchased.isNotEmpty {
                idSet = purchased
            } else {
                if let error {
                    Logger.shared.iap("validatePurchase error \(error)")
                }

                if let result, result.purchased.isEmpty {
                    Logger.shared.iap("validatePurchase result \(result)")
                }
            }
        }
    }

    var iapEnv: IAPEnvironment {
        guard let builder = config.envBuilder else {
            return .production
        }
        return builder()
    }

    func didPurchase(_ idSet: Set<String>, override: Bool, setPremium: Bool) {
        Logger.shared.iap("didPurchase \(idSet), override \(override), setPremium: \(setPremium)")

        if override {
            purchased = idSet
        } else {
            var list = purchased
            list.formUnion(idSet)
            if list.count != purchased.count {
                purchased = list
            }
        }

        if setPremium {
            isPremium = true
        }
    }

    //
    func resetPurchase(setPremium: Bool) {
        Logger.shared.iap("resetPurchase, setPremium \(setPremium)")

        if purchased.isNotEmpty {
            purchased = []
        }

        if setPremium {
            isPremium = false
        }
    }
}
