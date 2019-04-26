//
//  UserMonitorObject.swift
//  QuestsMaffia
//
//  Created by Alexander Zimin on 11/09/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation
import RealmSwift

public enum UserType: Int {
    case basic
    case pending
    case paying
    case notPaying
}

public final class UserMonitorObject: Object, ObjectSingletone {
    public static func create() -> Self {
        return self.init()
    }
    
    @objc public dynamic var lastPaymentTypeInt: Int = 0
    @objc public dynamic var userTypeInt: Int = 0
    @objc public dynamic var currencyPurchaseScore: Int = 0

    public var userType: UserType {
        get {
            return UserType(rawValue: self.userTypeInt) ?? .basic
        }
        set {
            realmWrite {
                self.userTypeInt = newValue.rawValue
            }
        }
    }

    public var lastPaymentType: UserMonitorService.PaymentType? {
        get {
            return UserMonitorService.PaymentType(rawValue: self.lastPaymentTypeInt)
        }
        set {
            realmWrite {
                self.lastPaymentTypeInt = newValue?.rawValue ?? 0
            }
        }
    }
}
