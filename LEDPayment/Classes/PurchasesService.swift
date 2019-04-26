//
//  PurchasesService.swift
//  QuestsMaffia
//
//  Created by Alex Zimin on 24/07/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation
import StoreKit
import SwiftyStoreKit
import LEDAnalytics
import LEDHelpers
import LEDCore

public class PurchasesService<Product, PurchaseHandler: PurchaseHandlerProtocol> where PurchaseHandler.Product == Product {
    
    private var products: [Product: SKProduct] = [:]
    private let analytics: AnalyticsServiceProtocol
    private let sharedSecret: String
    private let subscriptionsDataSource: SubscriptionsDataSourceProtocol
    private let purchaseHandler: PurchaseHandler

    public init(analytics: AnalyticsServiceProtocol,
                subscriptionsDataSource: SubscriptionsDataSourceProtocol,
                purchaseHandler: PurchaseHandler,
                sharedSecret: String) {
        self.analytics = analytics
        self.subscriptionsDataSource = subscriptionsDataSource
        self.purchaseHandler = purchaseHandler
        self.sharedSecret = sharedSecret
    }

    public func fetchAllProducts() {
        let allProducts = Product.allProducts.map({ $0.identifier })
        var allProductsSet = Set<String>()
        allProducts.forEach({ allProductsSet.insert($0) })

        SwiftyStoreKit.retrieveProductsInfo(allProductsSet) { (result) in
            self.products = [:]
            for product in result.retrievedProducts {
                if let productType = Product(identifier: product.productIdentifier) {
                    self.products[productType] = product
                } else {
                    appAssertionFailure("No such Product")
                }
            }
        }
    }

    public func getProduct(product: Product, completion: @escaping (SKProduct?) -> Void) {
        if let value = self.products[product] {
            completion(value)
            return
        }

        SwiftyStoreKit.retrieveProductsInfo(Set<String>(arrayLiteral: product.identifier)) { (result) in
            if let value = result.retrievedProducts.first {
                completion(value)
                self.fetchAllProducts()
            } else {
                completion(nil)
            }
        }
    }

    public func getProducts(products: [Product],
                            earlyAccessBlock: (([Product: SKProduct]) -> Void)?,
                            completion: @escaping ([Product: SKProduct]) -> Void) {
        var productsDictionary: [Product: SKProduct] = [:]
        for productType in products {
            if let product = self.products[productType] {
                productsDictionary[productType] = product
            }
        }

        if productsDictionary.count != products.count {
            if productsDictionary.count > 0 {
                earlyAccessBlock?(productsDictionary)
            }
        } else {
            completion(productsDictionary)
            return
        }

        let identifiers = products.map({ $0.identifier })
        SwiftyStoreKit.retrieveProductsInfo(Set<String>(identifiers)) { (result) in
            if result.retrievedProducts.count == identifiers.count {
                var productsDictionary: [Product: SKProduct] = [:]
                for product in result.retrievedProducts {
                    if let identifier = Product(identifier: product.productIdentifier) {
                        productsDictionary[identifier] = product
                    } else {
                        appAssertionFailure("No such Product")
                    }
                }
                completion(productsDictionary)
                self.fetchAllProducts()
            } else {
                completion([:])
            }
        }
    }

    public func purchaseProduct(with product: SKProduct, properties: [AnyHashable: Any], completion: @escaping PurchaseBlock) {
        guard let productType = Product(identifier: product.productIdentifier) else {
            appAssertionFailure("No such product")
            completion(.failed(error: nil))
            return
        }

        SwiftyStoreKit.purchaseProduct(product) { (result) in
            switch result {
            case .success(let purchase):
                SwiftyStoreKit.finishTransaction(purchase.transaction)

                if purchase.transaction.transactionState == .purchased {
                    let finalProperties = properties.byAppending(collection:
                        ["currency": purchase.product.currencyForAnalytics]
                    )

                    self.analytics.logRevenue(productId: purchase.product.productIdentifier,
                                              quantity: purchase.quantity,
                                              price: !productType.isTrial ? (productType.price as NSNumber) : (0 as NSNumber),
                                              revenueType: productType.analyticsName,
                                              receipt: SwiftyStoreKit.localReceiptData,
                                              properties: finalProperties)

                    self.purchaseHandler.newPurchaseHandled(type: productType.purchaseType, product: productType)
                }

                switch productType.purchaseType {
                case .product:
                    completion(.success)
                case .subscription:
                    self.verifySubscription(productType, completion: { (result) in
                        if let result = result {
                            self.purchased(productType, status: result, showProduct: purchase.product)
                            completion(.success)
                        } else {
                            completion(.failed(error: nil))
                        }
                    })
                }
            case .error(let error):
                switch error.code {
                case .paymentCancelled:
                    completion(.cancelled)
                default:
                    completion(.failed(error: error))
                    print("Another error")
                }
            }
        }
    }

    enum PuchaseStatus {
        case puchased
        case expired
        case notPurcahsed
    }

    typealias PriceInfo = (price: NSNumber, currency: String)

    func purchased(_ product: Product, status: VerifySubscriptionResult, showProduct: SKProduct?) {
        switch status {
        case let .purchased(_, items):
            for item in items {
                self.subscriptionsDataSource.formOrUpdateGameSubscriptionObject(
                    originalTransactionId: item.originalTransactionId,
                    transactionId: item.transactionId,
                    experiningDate: item.subscriptionExpirationDate,
                    isTrial: item.isTrialPeriod,
                    purchaseDate: item.purchaseDate,
                    productId: product.identifier,
                    price: nil,
                    currency: nil,
                    isPurchase: true,
                    showProduct: showProduct)
            }
        case let .expired(_, items):
            for item in items {
                self.subscriptionsDataSource.formOrUpdateGameSubscriptionObject(
                    originalTransactionId: item.originalTransactionId,
                    transactionId: item.transactionId,
                    experiningDate: item.subscriptionExpirationDate,
                    isTrial: item.isTrialPeriod,
                    purchaseDate: item.purchaseDate,
                    productId: product.identifier,
                    price: nil,
                    currency: nil,
                    isPurchase: false,
                    showProduct: showProduct)
            }
        case .notPurchased:
            break
        }

        self.subscriptionsDataSource.purchaseUpdated()
    }

    public func updateSubscriptionPurchases() {
        var identitfiers = Set<String>()
        for value in self.subscriptionsDataSource.currentSubscriptionsIdentifiers {
            identitfiers.insert(value)
        }

        for identitfier in identitfiers {
            if let purchase = Product(identifier: identitfier) {
                self.verifySubscription(purchase) { (result) in
                    if let result = result {
                        self.purchased(purchase, status: result, showProduct: nil)
                    }
                }
            }
        }
    }

    func verifySubscription(_ product: Product, completion: @escaping (VerifySubscriptionResult?) -> Void) {
        #if DEBUG
        let appleValidator = AppleReceiptValidator(service: .sandbox,
                                                   sharedSecret: self.sharedSecret)
        #else
        let appleValidator = AppleReceiptValidator(service: .production,
                                                   sharedSecret: self.sharedSecret)
        #endif

        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = product.identifier

                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt)

                completion(purchaseResult)
            case .error(let error):
                print("Receipt verification failed: \(error)")
                completion(nil)
            }
        }
    }

    public func restorePurchases(completion: (() -> Void)? = nil) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            for purchase in results.restoredPurchases {
                if let product = Product(identifier: purchase.productId) {
                    switch product.purchaseType {
                    case .subscription:
                        self.verifySubscription(product, completion: { (result) in
                            if let result = result {
                                self.purchased(product, status: result, showProduct: nil)
                            }
                        })
                    case .product:
                        self.purchaseHandler.newPurchaseHandled(type: product.purchaseType, product: product)
                    }
                }
            }
            completion?()
        }
    }
}

extension SKProduct {
    public var productLocalizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? ""
    }
}

extension SKProduct {
    public var currencyForAnalytics: String {
        return self.priceLocale.currencyCode ?? self.priceLocale.currencySymbol ?? self.productLocalizedPrice
    }
}
