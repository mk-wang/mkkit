//
//  IAPHelper.swift
//  TVRemote
//
//  Created by MK on 2023/2/10.
//

import CryptoKit
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
    struct ProductTransactionResult {
        public let productID: String
        public let purchased: Bool
    }

    static func startObserving(completion: @escaping ([ProductTransactionResult]) -> Void) {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            var list = [ProductTransactionResult]()
            for purchase in purchases {
                let productID = purchase.productId

                switch purchase.transaction.transactionState {
                case .purchased,
                     .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    list.append(ProductTransactionResult(productID: productID, purchased: true))
                case .failed:
                    list.append(ProductTransactionResult(productID: productID, purchased: false))
                case .deferred,
                     .purchasing:
                    break
                @unknown default: // .purchasing, .deferred
                    break
                }
            }
            completion(list)
        }
    }

    static func purchase(productID: String,
                         secret: String,
                         environment: IAPEnvironment,
                         subscription: Bool,
                         quantity: Int = 1,
                         atomically: Bool = true,
                         completion: @escaping (Bool, Error?) -> Void)
    {
        SwiftyStoreKit.purchaseProduct(productID,
                                       quantity: quantity,
                                       atomically: atomically) { purchaseResult in

            switch purchaseResult {
            case .success:
                guard environment != .local else {
                    completion(true, nil)
                    return
                }
                if subscription {
                    Self.verifySubscription(productID: productID,
                                            secret: secret,
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
}
