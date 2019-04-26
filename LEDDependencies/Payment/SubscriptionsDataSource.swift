//
//  SubscriptionsDataSource.swift
//  LEDDependencies
//
//  Created by Alexander Zimin on 27/04/2019.
//  Copyright © 2019 led. All rights reserved.
//

import Foundation
import StoreKit
import LEDCore
import LEDAnalytics
import LEDPayment

public class SubscriptionsDataSource<Product, PurchaseHandler: PurchaseHandlerProtocol>: SubscriptionsDataSourceProtocol where PurchaseHandler.Product == Product {

    private let analyticsService: AnalyticsServiceProtocol
    private let userMonitor: UserMonitorService
    private var purchasesService: PurchasesService<Product, PurchaseHandler>?

    public init(analyticsService: AnalyticsServiceProtocol,
                userMonitor: UserMonitorService) {
        self.analyticsService = analyticsService
        self.userMonitor = userMonitor
    }

    public func setup(purchasesService: PurchasesService<Product, PurchaseHandler>) {
        self.purchasesService = purchasesService
    }

    public var currentSubscriptionsIdentifiers: [String] {
        if let realm = RealmController.shared.mainRealm {
            let subscriptions = realm.objects(GameSubscriptionObject.self)
            return subscriptions.map({ $0.productId })
        } else {
            return []
        }
    }

    public func purchaseUpdated() {
        let type: String
        if let currentSubscription = GameSubscriptionObject.currentSubsctription(date: Date()) {
            type = currentSubscription.isTrial ? "trial" : currentSubscription.productId
        } else {
            type = "no"
        }
        self.analyticsService.setPersonProperty(name: "current_subscription", value: type as NSObject)
    }

    public func formOrUpdateGameSubscriptionObject(originalTransactionId: String, transactionId: String, experiningDate: Date?, isTrial: Bool, purchaseDate: Date?, productId: String, price: NSNumber?, currency: String?, isPurchase: Bool, showProduct: SKProduct?) {

        let object = GameSubscriptionObject.formOrUpdateGameSubscriptionObject(
            originalTransactionId: originalTransactionId,
            transactionId: transactionId,
            experiningDate: experiningDate,
            isTrial: isTrial,
            purchaseDate: purchaseDate,
            productId: productId,
            price: price,
            currency: currency)


        if isPurchase {
            if let showProduct = showProduct {
                object.updatePrice(from: showProduct)
            }

            if !object.isSentWithPrice && object.currency == nil {
                if let product = Product(identifier: object.productId) {
                    appAssert(self.purchasesService != nil, "Purchase service should exist")
                    self.purchasesService?.getProduct(product: product) { (showProduct) in
                        if let showProduct = showProduct {
                            object.updatePrice(from: showProduct)
                            object.logItemIfNeeded(analyticsService: self.analyticsService, userMonitor: self.userMonitor)
                        }
                    }
                }
            } else {
                object.logItemIfNeeded(analyticsService: self.analyticsService, userMonitor: self.userMonitor)
            }
        }
    }
}
