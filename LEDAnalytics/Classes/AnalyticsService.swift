//
//  AnalyticsService.swift
//  LEDAnalytics
//
//  Created by Alexander Zimin on 26/04/2019.
//  Copyright © 2019 led. All rights reserved.
//

import Foundation
import Amplitude_iOS
import FacebookCore
import FBSDKCoreKit
import LEDCore
import LEDProductCore
import StoreKit

public class AnalyticsService: AnalyticsServiceProtocol, ProductAnalyticsServiceProtocol {
    private var storage: StorageServiceProtocol
    private var apmplitudeId: String?
    private var hasFacebook: Bool
    private var additionalServices: [AnalyticsAdditionalService]

    public init(storage: StorageServiceProtocol, apmplitudeId: String?, hasFacebook: Bool, shouldTrackAdIdentifier: Bool, additionalServices: [AnalyticsAdditionalService]) {
        self.storage = storage
        self.apmplitudeId = apmplitudeId
        self.hasFacebook = hasFacebook
        self.additionalServices = additionalServices

        if let id = apmplitudeId {
            Amplitude.instance().initializeApiKey(id)
            Amplitude.instance().setUserId(self.userId)
            #if DEBUG
            Amplitude.instance().optOut = true
            #endif
        }

        if hasFacebook {
            FBSDKAppEvents.activateApp()
            FBSDKAppEvents.setUserID(self.userId)
        }

        self.additionalServices.forEach({ $0.setup(id: self.userId) })

//        if shouldTrackAdIdentifier, ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
//            let adIdentifier = ASIdentifierManager.shared().advertisingIdentifier.uuidString
//            self.setPersonProperty(name: "ad_id", value: adIdentifier as NSObject)
//        }
    }

    public var userId: String {
        var id: String
        if let cachedId = self.storage.getObject(for: "auth0-user-id") as String? {
            id = cachedId
        } else {
            let newId = UUID().uuidString
            self.storage.save(object: newId, for:"auth0-user-id")
            id = newId
        }
        return id
    }

    public func buildCohordPair() -> (cohordDay: Int, cohordWeek: Int, cohordMonth: Int) {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        let month = calendar.component(.month, from: Date())
        let day = calendar.ordinality(of: .day, in: .year, for: Date())
        return (day ?? 0, weekOfYear, month)
    }

    public func logEvent(name: String, properties: [AnyHashable: Any]? = nil) {
        if let properties = properties {
            Amplitude.instance().logEvent(name, withEventProperties: properties)
            AppEventsLogger.log(AppEvent(name: name, parameters: self.convertToFB(properties: properties), valueToSum: nil))
        } else {
            Amplitude.instance().logEvent(name)
            AppEventsLogger.log(AppEvent(name: name))
        }
        self.additionalServices.forEach({ $0.logEvent(name: name, properties: properties) })
    }

    public func logEvent(name: String) {
        self.logEvent(name: name, properties: nil)
    }

    public func logEventOnce(name: String, properties: [AnyHashable: Any]? = nil) {
        let udKey = self.storageEventKey(with: name)
        if (self.storage.getObject(for: udKey) as Bool?) == true {
            return
        }

        self.logEvent(name: name, properties: properties)
        self.storage.save(object: true, for: udKey)
    }

    public func logEventOnce(name: String) {
        self.logEventOnce(name: name, properties: nil)
    }

    public func setPersonProperty(name: String, value: NSObject) {
        let identify = AMPIdentify().set(name, value: value)
        Amplitude.instance().identify(identify)
        AppEventsLogger.updateUserProperties([name: value], completion: { (_, _) in })
        self.additionalServices.forEach({ $0.setPersonProperty(name: name, value: value) })
    }

    public func setPersonPropertyOnce(name: String, value: NSObject) {
        let identify = AMPIdentify().setOnce(name, value: value)
        Amplitude.instance().identify(identify)

        let udKey = self.storageUserPropertiesKey(with: name)
        if (self.storage.getObject(for: udKey) as Bool?) == nil {
            // FIXME: - Rething logic if completion would be false
            AppEventsLogger.updateUserProperties([name: value], completion: { (_, _) in })
            self.additionalServices.forEach({ $0.setPersonProperty(name: name, value: value) })
            self.storage.save(object: true, for: udKey)

            let udValueKey = self.storageUserPropertiesValueKey(with: name)
            self.storage.save(object: value, for: udValueKey)
        }
    }

    public func increasePersonProperty(name: String, by value: Int) {
        let identify = AMPIdentify().add(name, value: value as NSObject)
        Amplitude.instance().identify(identify)

        let udKey = self.storageUserPropertiesKey(with: name)
        let storedValue = self.storage.getObject(for: udKey) as Int?
        var newValue: Int = storedValue ?? 0
        newValue += value
        self.storage.save(object: newValue, for: udKey)
        AppEventsLogger.updateUserProperties([name: newValue], completion: { (_, _) in })
        self.additionalServices.forEach({ $0.setPersonProperty(name: name, value: "\(value)" as NSObject) })
    }

    public func logRevenue(productId: String, quantity: Int, price: NSNumber, revenueType: String, receipt: Data?, properties: [AnyHashable: Any]? = nil) {
        var revenue = AMPRevenue().setProductIdentifier(productId).setQuantity(quantity).setPrice(price).setRevenueType(revenueType)
        if let receipt = receipt {
            revenue = revenue?.setReceipt(receipt)
        }
        if let properties = properties {
            revenue = revenue?.setEventProperties(properties)
        }
        Amplitude.instance().logRevenueV2(revenue)
        self.additionalServices.forEach({ $0.logRevenue(receipt: receipt) })
    }

    public func loggedOnceValue(for key: String) -> NSObject? {
        return self.storage.getObject(for: self.storageUserPropertiesValueKey(with: key)) as NSObject?
    }

    // MARK: - Helpers

    private func convertToFB(properties: [AnyHashable: Any]) -> AppEvent.ParametersDictionary {
        var parametrs: AppEvent.ParametersDictionary = [:]
        for (key, value) in properties {
            if let key = key as? String,
                let value = value as? AppEventParameterValueType {
                parametrs[.custom(key)] = value
            }
        }
        return parametrs
    }

    private func storageUserPropertiesKey(with name: String) -> String {
        return "_analtytics-reports.up.\(name)"
    }

    private func storageUserPropertiesValueKey(with name: String) -> String {
        return "_analtytics-reports.up.value.\(name)"
    }

    private func storageEventKey(with name: String) -> String {
        return "_analtytics-reports.event.\(name)"
    }
}
