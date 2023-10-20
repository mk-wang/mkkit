//
//  IAPHelper.swift
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

// MARK: - PurchaseInfo

public class PurchaseInfo {
    public fileprivate(set) var details: PurchaseDetails?
    public fileprivate(set) var result: PurchaseResult?
    public fileprivate(set) var receipt: ReceiptInfo?
    public fileprivate(set) var purchaseResult: VerifyPurchaseResult?
    public fileprivate(set) var subscriptionResult: VerifySubscriptionResult?
}

// MARK: - RestoreInfo

public class RestoreInfo {
    public let restoreResults: RestoreResults

    public internal(set) var receipt: ReceiptInfo?
    public internal(set) var purchaseResult: IAPHelper.PurchaseResult?

    public init(restoreResults: RestoreResults) {
        self.restoreResults = restoreResults
    }
}

public extension IAPHelper {
    struct PurchaseResult {
        public let purchased: Set<String>
        public let failed: Set<String>
        public let expired: Set<String>?
        public let finished: Set<String>?
    }

    static func startObserving(completion: @escaping ([Purchase], [Purchase], PurchaseResult) -> Void) {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            var failed = Set<String>()
            var purchased = Set<String>()
            var finished: Set<String>?

            var finishedPurchase = [Purchase]()

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
                        finishedPurchase.append(purchase)
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
            completion(purchases, finishedPurchase, result)
        }
    }

    static func purchase(productID: String,
                         secret: String,
                         environment: IAPEnvironment,
                         subscription: Bool,
                         validDuration: TimeInterval? = nil,
                         quantity: Int = 1,
                         atomically: Bool = true,
                         completion: @escaping (Bool, PurchaseInfo?, Error?) -> Void)
    {
        SwiftyStoreKit.purchaseProduct(productID,
                                       quantity: quantity,
                                       atomically: atomically)
        { purchaseResult in

            switch purchaseResult {
            case let .success(detail):
                guard environment != .local else {
                    completion(true, nil, nil)
                    return
                }
                var info = PurchaseInfo()
                info.details = detail
                if subscription {
                    verifySubscription(productID: productID,
                                       secret: secret,
                                       validDuration: validDuration,
                                       environment: environment)
                    { suc, receipt, result, error in
                        if suc {
                            info.receipt = receipt
                            info.subscriptionResult = result
                            completion(suc, info, error)
                        } else {
                            completion(suc, nil, error)
                        }
                    }
                } else {
                    verifyPurchase(productID: productID,
                                   secret: secret,
                                   environment: environment)
                    { suc, receipt, result, error in
                        if suc {
                            info.receipt = receipt
                            info.purchaseResult = result
                            completion(suc, info, error)
                        } else {
                            completion(suc, nil, error)
                        }
                    }
                }

            case let .error(error: error):
                completion(false, nil, error)
            }
        }
    }

    static func restore(completion: @escaping (RestoreInfo) -> Void) {
        SwiftyStoreKit.restorePurchases { results in
            let info = RestoreInfo(restoreResults: results)
            completion(info)
        }
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
                               completion: @escaping (Bool, ReceiptInfo?, VerifyPurchaseResult?, Error?) -> Void)
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
                    completion(true, receipt, purchaseResult, nil)
                case .notPurchased:
                    completion(false, receipt, purchaseResult, nil)
                }
            case let .error(error: error):
                completion(false, nil, nil, error)
            }
        }
    }

    static func verifySubscription(productID: String,
                                   secret: String,
                                   validDuration: TimeInterval? = nil,
                                   environment: IAPEnvironment,
                                   completion: @escaping (Bool, ReceiptInfo?, VerifySubscriptionResult?, Error?) -> Void)
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
                    completion(true, receipt, purchaseResult, nil)
                case .expired:
                    completion(false, receipt, purchaseResult, nil)
                case .notPurchased:
                    completion(false, receipt, purchaseResult, nil)
                }
            case let .error(error):
                completion(false, nil, nil, error)
            }
        }
    }

    static func verifyPurchase(products: [String]? = nil,
                               subscriptions: [String]? = nil,
                               secret: String,
                               forceRefresh: Bool,
                               environment: IAPEnvironment,
                               completion: @escaping (ReceiptInfo?, PurchaseResult?, Error?) -> Void)
    {
        guard environment != .local else {
            completion(nil, nil, nil)
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
                completion(receipt, result, nil)
            case let .error(error):
                completion(nil, nil, error)
            }
        }
    }
}
