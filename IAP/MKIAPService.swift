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
        public let setPremiumIfPurchased: Bool
        public let resetIfVerificationFailed: Bool

        public let passbyLocalVerification: Bool
        public let envBuilder: ValueBuilder<IAPEnvironment>?

        public init(setPremiumIfPurchased: Bool,
                    resetIfVerificationFailed: Bool,
                    passbyLocalVerification: Bool = false,
                    envBuilder: ValueBuilder<IAPEnvironment>? = nil)
        {
            self.setPremiumIfPurchased = setPremiumIfPurchased
            self.passbyLocalVerification = passbyLocalVerification
            self.resetIfVerificationFailed = resetIfVerificationFailed
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
            Logger.shared.iap("isPremium \(newValue)")
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
    public func purchase(product: MKIAPProduct, completion: ((Bool, PurchaseInfo?) -> Void)? = nil) {
        let productID = product.id
        IAPHelper.purchase(productID: productID,
                           secret: sharedSecret,
                           environment: iapEnv,
                           subscription: product.isSubscription)
        { [weak self] suc, info, error in
            Logger.shared.iap("purchase \(productID) \(suc) error \(error?.localizedDescription ?? "null")")

            if suc {
                self?.didPurchase([productID], override: false)
            }
            completion?(suc, info)
        }
    }

    public func checkAtAppStart(completion: (([Purchase], [Purchase], IAPHelper.PurchaseResult) -> Void)? = nil) {
        isPremium = purchased.isNotEmpty

        Logger.shared.iap("checkAtAppStart purchased \(purchased)")

        do {
            IAPHelper.startObserving { [weak self] all, finished, result in
                Logger.shared.iap("checkAtAppStart observing  \(result.purchased) ")

                if !result.purchased.isEmpty {
                    self?.validatePurchase(forceRefresh: true)
                }

                completion?(all, finished, result)
            }
        }

        if isPremium {
            validatePurchase(forceRefresh: true)
        }

        loadProducts()
    }

    public func restorePurchase(completion: ((Bool, RestoreInfo) -> Void)? = nil) {
        IAPHelper.restore { [weak self] info in
            let results = info.restoreResults
            let restoreSuc = results.restoredPurchases.isNotEmpty
            Logger.shared.iap("restorePurchase \(restoreSuc) ")

            if restoreSuc {
                self?.validatePurchase(forceRefresh: true,
                                       callback: { suc, receipt, result in
                                           info.receipt = receipt
                                           info.purchaseResult = result
                                           completion?(suc, info)
                                       })
            } else {
                completion?(false, info)
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

    func validatePurchase(forceRefresh: Bool,
                          callback: ((Bool, ReceiptInfo?, IAPHelper.PurchaseResult?) -> Void)? = nil)
    {
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

        Logger.shared.iap("validatePurchase forceRefresh \(forceRefresh)")

        let passbyLocalVerification = config.passbyLocalVerification

        IAPHelper.verifyPurchase(products: products,
                                 subscriptions: subscriptions,
                                 secret: sharedSecret,
                                 forceRefresh: forceRefresh,
                                 environment: environment)
        { [weak self] receipt, result, error in
            var idSet: Set<String>?

            defer {
                if let idSet {
                    self?.didPurchase(idSet, override: true)
                    callback?(true, receipt, result)
                } else {
                    self?.resetPurchase()
                    callback?(false, receipt, result)
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

    func didPurchase(_ idSet: Set<String>, override: Bool) {
        Logger.shared.iap("didPurchase \(idSet), override \(override)")

        if override {
            purchased = idSet
        } else {
            var list = purchased
            list.formUnion(idSet)
            if list.count != purchased.count {
                purchased = list
            }
        }

        if !isPremium, config.setPremiumIfPurchased {
            isPremium = true
        }
    }

    //
    func resetPurchase() {
        Logger.shared.iap("resetPurchase")

        if purchased.isNotEmpty {
            purchased = []
        }

        if isPremium, config.resetIfVerificationFailed {
            isPremium = false
        }
    }
}
