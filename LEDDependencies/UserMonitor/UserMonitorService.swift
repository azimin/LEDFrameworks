//
//  UserMonitorService.swift
//  QuestsMaffia
//
//  Created by Alexander Zimin on 11/09/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation
import LEDAnalytics

public class UserMonitorService {
    private let analyticsService: AnalyticsServiceProtocol

    public init(analyticsService: AnalyticsServiceProtocol) {
        self.analyticsService = analyticsService
    }

    public enum PaymentType: Int {
        case none = 0
        case trial = 1
        case subscriber = 2
        case currency = 3
        case platinum = 4

        var analyticsName: String {
            switch self {
            case .none:
                return "none"
            case .trial:
                return "trial"
            case .subscriber:
                return "subscriber"
            case .currency:
                return "currency"
            case .platinum:
                return "platinum"
            }
        }
    }

    public var paymentType: PaymentType {
        return UserMonitorObject.value.lastPaymentType ?? .none
    }

    public var userType: UserType {
        return UserMonitorObject.value.userType
    }

    public func reportCurrencyPurchase() {
        var type = UserMonitorObject.value.lastPaymentType ?? .none
        let oldValue = type

        switch type {
        case .none, .trial:
            type = .currency
        case .subscriber:
            type = .platinum
        case .platinum, .currency:
            break
        }

        if oldValue != type {
            UserMonitorObject.value.userType = .paying
            UserMonitorObject.value.lastPaymentType = type
            self.analyticsService.setPersonProperty(name: "payment_type",
                                                    value: type.analyticsName as NSObject)
        }
    }

    public func reportSubscription(isTrial: Bool) {
        var type = UserMonitorObject.value.lastPaymentType ?? .none
        let oldValue = type

        switch type {
        case .none, .trial:
            type = isTrial ? .trial : .subscriber
        case .currency:
            type = isTrial ? .currency : .platinum
        case .platinum, .subscriber:
            break
        }

        if oldValue != type {
            UserMonitorObject.value.userType = .paying
            UserMonitorObject.value.lastPaymentType = type
            self.analyticsService.setPersonProperty(name: "payment_type",
                                                    value: type.analyticsName as NSObject)
        }
    }

    public func reportCurrencyPurchaseScoreAdd(value: Int) {
        realmWrite {
            UserMonitorObject.value.currencyPurchaseScore += value
        }
    }
}
