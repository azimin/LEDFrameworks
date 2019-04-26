//
//  SubscriptionsDataSourceProtocol.swift
//  PurchaseCore
//
//  Created by Alexander Zimin on 23/09/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation
import StoreKit

public protocol SubscriptionsDataSourceProtocol {
    var currentSubscriptionsIdentifiers: [String] { get }
    func purchaseUpdated()
    func formOrUpdateGameSubscriptionObject(originalTransactionId: String, transactionId: String, experiningDate: Date?, isTrial: Bool, purchaseDate: Date?, productId: String, price: NSNumber?, currency: String?, isPurchase: Bool, showProduct: SKProduct?)
}
