//
//  GameSubscriptionObject.swift
//  QuestsMaffia
//
//  Created by Alexander Zimin on 02/08/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation
import RealmSwift
import StoreKit
import LEDPayment
import LEDAnalytics

extension Notification.Name {
    public static let subscriptionUpdated = Notification.Name("subscriptionUpdated")
}

public final class GameSubscriptionObject: Object {
    public static var isSubscribed: Bool {
        if RealmController.shared.mainRealm == nil {
            return UserDefaults.standard.bool(forKey: subscriptionKey)
        } else {
            return GameSubscriptionObject.hasCurrentSubscription(date: Date())
        }
    }
    
    // Main information
    @objc public dynamic var experiningDate: Date?
    @objc public dynamic var transactionId: String = ""
    @objc public dynamic var originalTransactionId: String = ""
    @objc public dynamic var isTrial: Bool = true
    @objc public dynamic var purchaseDate: Date?
    @objc public dynamic var productId: String = ""

    // Price
    @objc public dynamic var price: Float = 0
    @objc public dynamic var currency: String?

    // Utils
    @objc public dynamic var isSentWithPrice: Bool = false
    @objc public dynamic var isSentWithoutPrice: Bool = false

    private static let subscriptionKey = "bp.application_has_subscription"

    @discardableResult
    public static func formOrUpdateGameSubscriptionObject(originalTransactionId: String, transactionId: String, experiningDate: Date?, isTrial: Bool, purchaseDate: Date?, productId: String, price: NSNumber?, currency: String?) -> GameSubscriptionObject {
        let value: GameSubscriptionObject
        var isNewSubscriptionAppears = false
        if let object = RealmController.shared.mainRealm?.objects(GameSubscriptionObject.self).filter("transactionId == %@", transactionId).first {
            value = object
        } else {
            isNewSubscriptionAppears = true
            value = GameSubscriptionObject()
            value.originalTransactionId = originalTransactionId
            realmWrite {
                RealmController.shared.mainRealm?.add(value)
            }
        }

        realmWrite {
            value.transactionId = transactionId
            value.experiningDate = experiningDate
            value.isTrial = isTrial
            value.purchaseDate = purchaseDate
            value.productId = productId
            value.price = price?.floatValue ?? value.price
            value.currency = currency ?? value.currency
        }

        if isNewSubscriptionAppears {
            NotificationCenter.default.post(name: .subscriptionUpdated, object: nil)
        }

        if RealmController.shared.mainRealm == nil {
            UserDefaults.standard.set(true, forKey: subscriptionKey)
        }

        print("Subscription object create, new: \(isNewSubscriptionAppears), object: \(value)")

        return value
    }

    public func updatePrice(from product: SKProduct) {
        realmWrite {
            self.price = product.price.floatValue
            self.currency = product.currencyForAnalytics
        }
    }

    public func logItemIfNeeded(analyticsService: AnalyticsServiceProtocol, userMonitor: UserMonitorService) {
        if !self.isSentWithPrice && self.currency != nil {
            self.logItem(analyticsService: analyticsService, userMonitor: userMonitor)
        } else if !self.isSentWithoutPrice {
            self.logItem(analyticsService: analyticsService, userMonitor: userMonitor)
        }
    }

    private func logItem(analyticsService: AnalyticsServiceProtocol, userMonitor: UserMonitorService) {
        let originalTransactionId = self.originalTransactionId
        let transactionId = self.transactionId
        let subscriptionExpirationDate = self.experiningDate ?? Date()
        let isTrialPeriod = self.isTrial
        let purchaseDate = self.purchaseDate ?? Date()

        var keys: [AnyHashable: Any] = ["original_transaction_id": originalTransactionId,
                                        "transaction_id": transactionId,
                                        "subscription_expiration_date": subscriptionExpirationDate,
                                        "is_trial_period": isTrialPeriod,
                                        "purchase_date": purchaseDate]

        if let currency = self.currency {
            keys["price"] = self.price
            keys["currency"] = currency
            keys["with_price"] = true
            realmWrite {
                self.isSentWithPrice = true
            }
        } else {
            keys["with_price"] = false
        }

        realmWrite {
            self.isSentWithoutPrice = true
        }

        analyticsService.logEvent(name: "Purchase Receipt", properties: keys)
        userMonitor.reportSubscription(isTrial: self.isTrial)
    }

    public static func subscription(by transactionId: String) -> GameSubscriptionObject? {
        return RealmController.shared.mainRealm?.objects(GameSubscriptionObject.self).filter("transactionId == %@", transactionId).first
    }

    public static func currentSubsctription(date: Date, movedTimeInterval: TimeInterval = 0) -> GameSubscriptionObject? {
        let bottomDate = date.addingTimeInterval(-movedTimeInterval)
        return RealmController.shared.mainRealm?.objects(GameSubscriptionObject.self).filter("experiningDate > %@ AND purchaseDate <= %@", bottomDate, date).sorted(byKeyPath: "experiningDate", ascending: false).first
    }

    public static func hasCurrentSubscription(date: Date) -> Bool {
        #if DEBUG
        let movedTimeInterval: TimeInterval = 60
        #else
        let movedTimeInterval: TimeInterval = 60 * 60 * 2
        #endif
        return self.currentSubsctription(date: date, movedTimeInterval: movedTimeInterval) != nil
    }
}
