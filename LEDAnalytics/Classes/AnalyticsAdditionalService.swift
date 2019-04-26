//
//  AnalyticsService.swift
//  LEDAnalytics
//
//  Created by Alexander Zimin on 26/04/2019.
//  Copyright © 2019 led. All rights reserved.
//

import Foundation

public protocol AnalyticsServiceProtocol {
    var userId: String { get }
    func buildCohordPair() -> (cohordDay: Int, cohordWeek: Int, cohordMonth: Int)

    func logEvent(name: String, properties: [AnyHashable: Any]?)
    func logEvent(name: String)

    func logEventOnce(name: String, properties: [AnyHashable: Any]?)
    func logEventOnce(name: String)

    func setPersonProperty(name: String, value: NSObject)
    func setPersonPropertyOnce(name: String, value: NSObject)

    func increasePersonProperty(name: String, by value: Int)
    func logRevenue(productId: String, quantity: Int, price: NSNumber, revenueType: String, receipt: Data?, properties: [AnyHashable: Any]?)

    func loggedOnceValue(for key: String) -> NSObject?
}

extension AnalyticsServiceProtocol {
    func setPersonProperty(name: String, value: Any) {
        if let value = value as? NSObject {
            self.setPersonProperty(name: name, value: value)
        }
    }

    func setPersonPropertyOnce(name: String, value: Any) {
        if let value = value as? NSObject {
            self.setPersonPropertyOnce(name: name, value: value)
        }
    }
}
