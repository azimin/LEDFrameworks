//
//  AnalyticsAdditionalService.swift
//  AnalyticsCore
//
//  Created by Alexander Zimin on 05/11/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation
import StoreKit

public protocol AnalyticsAdditionalService {
    func setup(id: String)
    func logEvent(name: String, properties: [AnyHashable: Any]?)
    func logEventOnce(name: String, properties: [AnyHashable: Any]?)
    func setOnce(name: String, value: NSObject)
    func setPersonProperty(name: String, value: NSObject)
    func addPersonProperty(name: String, by value: Int)
    func logRevenue(receipt: Data?)
    func logPurchase(product: SKProduct, transaction: SKPaymentTransaction, properties: [AnyHashable: Any]?)
}
