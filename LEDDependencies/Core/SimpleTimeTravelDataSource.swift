//
//  AppTimeTravelDataSource.swift
//  LEDDependencies
//
//  Created by Alexander Zimin on 27/04/2019.
//  Copyright © 2019 led. All rights reserved.
//

import Foundation
import LEDCore

public class SimpleTimeTravelDataSource: TimeTravelDataSourceProtocol {
    public init() { }

    public var shouldReturnTimerDate: Bool {
        return !GameSubscriptionObject.isSubscribed
    }

    private var timeEndDateKey = "led_dependencies_timer_timerEndDate"
    public var timerEndDate: Date? {
        set {
            if let timerEndDate = newValue {
                UserDefaults.standard.set(timerEndDate, forKey: timeEndDateKey)
            } else {
                UserDefaults.standard.removeObject(forKey: timeEndDateKey)
            }
        }
        get {
            return UserDefaults.standard.object(forKey: timeEndDateKey) as? Date
        }
    }

    private var lastLoadedDateKey = "led_dependencies_timer_lastLoadedDate"
    public var lastLoadedDate: Date? {
        set {
            if let lastLoadedDate = newValue {
                UserDefaults.standard.set(lastLoadedDate, forKey: lastLoadedDateKey)
            } else {
                UserDefaults.standard.removeObject(forKey: lastLoadedDateKey)
            }
        }
        get {
            return UserDefaults.standard.object(forKey: lastLoadedDateKey) as? Date
        }
    }
}
