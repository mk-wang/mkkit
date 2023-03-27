//
//  IAPHelper.swift
//  TVRemote
//
//  Created by MK on 2023/2/10.
//

import Foundation
import StoreKit
import SwiftyStoreKit

// MARK: - IAPHelper

public enum IAPHelper {}

// MARK: - IAPEnvironment

public enum IAPEnvironment {
    case production
    case sandbox
    case local
}

public extension IAPHelper {
    struct PurchaseResult {
        public let purchased: Set<String>
        public let failed: Set<String>
        public let expired: Set<String>?
        public let finished: Set<String>?
    }

    static func startObserving(completion: @escaping (PurchaseResult) -> Void) {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            var failed = Set<String>()
            var purchased = Set<String>()
            var finished: Set<String>?

            for purchase in purchases {
                let productID = purchase.productId

                switch purchase.transaction.transactionState {
                case .purchased,
                     .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                        if finished == nil {
                            finished = Set()
                        }
                        finished?.insert(productID)
                    }
                    purchased.insert(productID)
                case .failed:
                    failed.insert(productID)
                case .deferred,
                     .purchasing:
                    break
                @unknown default: // .purchasing, .deferred
                    break
                }
            }

            let result = PurchaseResult(purchased: purchased, failed: failed, expired: nil, finished: finished)
            completion(result)
        }
    }

    static func purchase(productID: String,
                         secret: String,
                         environment: IAPEnvironment,
                         subscription: Bool,
                         validDuration: TimeInterval? = nil,
                         quantity: Int = 1,
                         atomically: Bool = true,
                         completion: @escaping (Bool, Error?) -> Void)
    {
        SwiftyStoreKit.purchaseProduct(productID,
                                       quantity: quantity,
                                       atomically: atomically)
        { purchaseResult in

            switch purchaseResult {
            case .success:
                guard environment != .local else {
                    completion(true, nil)
                    return
                }
                if subscription {
                    Self.verifySubscription(productID: productID,
                                            secret: secret,
                                            validDuration: validDuration,
                                            environment: environment,
                                            completion: completion)
                } else {
                    Self.verifyPurchase(productID: productID,
                                        secret: secret,
                                        environment: environment,
                                        completion: completion)
                }

            case let .error(error: error):
                completion(false, error)
            }
        }
    }

    static func restore(completion: @escaping (RestoreResults) -> Void) {
        SwiftyStoreKit.restorePurchases(completion: completion)
    }

    static func restore(productID: String, completion: @escaping (Bool) -> Void) {
        SwiftyStoreKit.restorePurchases { restoreResults in
            var suc = !restoreResults.restoredPurchases.isEmpty
                && restoreResults.restoreFailedPurchases.isEmpty
            if suc {
                var found = false
                for item in restoreResults.restoredPurchases {
                    if item.productId == productID {
                        found = true
                        break
                    }
                }
                suc = found
            }
            completion(suc)
        }
    }

    static func getList(productList: [String], completion: @escaping (RetrieveResults) -> Void) {
        SwiftyStoreKit.retrieveProductsInfo(Set<String>.init(productList), completion: completion)
    }

    static func verifyPurchase(productID: String,
                               secret: String,
                               environment: IAPEnvironment,
                               completion: @escaping (Bool, Error?) -> Void)
    {
        let appleValidator = AppleReceiptValidator(service: environment == .production ? .production : .sandbox,
                                                   sharedSecret: secret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { verifyResult in
            switch verifyResult {
            case let .success(receipt):
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productID,
                    inReceipt: receipt
                )
                switch purchaseResult {
                case .purchased:
                    completion(true, nil)
                case .notPurchased:
                    completion(false, nil)
                }
            case let .error(error: error):
                completion(false, error)
            }
        }
    }

    static func verifySubscription(productID: String,
                                   secret: String,
                                   validDuration: TimeInterval? = nil,
                                   environment: IAPEnvironment,
                                   completion: @escaping (Bool, Error?) -> Void)
    {
        let appleValidator = AppleReceiptValidator(service: environment == .production ? .production : .sandbox,
                                                   sharedSecret: secret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case let .success(receipt):
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: validDuration == nil ? .autoRenewable : .nonRenewing(validDuration: validDuration!),
                    productId: productID,
                    inReceipt: receipt
                )

                switch purchaseResult {
                case .purchased:
                    completion(true, nil)
                case .expired:
                    completion(false, nil)
                case .notPurchased:
                    completion(false, nil)
                }
            case let .error(error):
                completion(false, error)
            }
        }
    }

    static func verifyPurchase(products: [String]? = nil,
                               subscriptions: [String]? = nil,
                               secret: String,
                               forceRefresh: Bool,
                               environment: IAPEnvironment,
                               completion: @escaping (PurchaseResult?, Error?) -> Void)
    {
        guard environment != .local else {
            completion(nil, nil)
            return
        }

        let appleValidator = AppleReceiptValidator(service: environment == .production ? .production : .sandbox,
                                                   sharedSecret: secret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: forceRefresh) { result in
            switch result {
            case let .success(receipt):
                var failed = Set<String>()
                var purchased = Set<String>()
                var expired = Set<String>()

                if let products {
                    for id in products {
                        let purchaseResult = SwiftyStoreKit.verifyPurchase(
                            productId: id,
                            inReceipt: receipt
                        )
                        switch purchaseResult {
                        case .purchased:
                            purchased.insert(id)
                        case .notPurchased:
                            failed.insert(id)
                        }
                    }
                }

                if let subscriptions {
                    for id in subscriptions {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable,
                                                                               productId: id,
                                                                               inReceipt: receipt)
                        switch purchaseResult {
                        case .purchased:
                            purchased.insert(id)
                        case .notPurchased:
                            failed.insert(id)
                        case .expired:
                            expired.insert(id)
                        }
                    }
                }
                let result = PurchaseResult(purchased: purchased, failed: failed, expired: expired, finished: nil)
                completion(result, nil)
            case let .error(error):
                completion(nil, error)
            }
        }
    }
}
