//
//  SplitTestingService.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation
import UIKit
import LEDCore

public class SplitTestingService {
    private let analyticsService: AnalyticsServiceProtocol
    private let storage: StorageServiceProtocol

    public init(analyticsService: AnalyticsServiceProtocol, storage: StorageServiceProtocol) {
        self.analyticsService = analyticsService
        self.storage = storage
    }

    public func fetchSplitTest<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Value {
        if let value = self.getGroup(splitTestType) {
            return Value(currentGroup: value, analytics: self.analyticsService)
        }

        let randomGroup = self.randomGroup(Value.self)
        self.saveGroup(splitTestType, group: randomGroup)
        return Value(currentGroup: randomGroup, analytics: self.analyticsService)
    }

    public func isGroupForSplitTestExist<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Bool {
        return self.getGroup(splitTestType) != nil
    }

    public func saveGroup<Value: SplitTestProtocol>(_ splitTestType: Value.Type, group: Value.GroupType) {
        self.storage.save(object: group.rawValue, for: Value.dataBaseKey)
    }

    public func getGroup<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Value.GroupType? {
        guard let stringValue = self.storage.getObject(for: Value.dataBaseKey) as String? else {
            return nil
        }
        return Value.GroupType(rawValue: stringValue)
    }

    private func randomGroup<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Value.GroupType {
        if self.checkGroup(splitTestType) {
            let random = CGFloat.random(in: 0...1)
            var sum: CGFloat = 0
            for value in Value.GroupType.testGroups {
                if sum <= random && sum + (value.probability ?? 0) > random {
                    return value
                }
                sum += value.probability ?? 0
            }
        }

        let count = Value.GroupType.testGroups.count
        let random = Int.random(in: 0..<count)
        return Value.GroupType.testGroups[random]
    }

    private func checkGroup<Value: SplitTestProtocol>(_ splitTestType: Value.Type) -> Bool {
        var sum: CGFloat = 0
        var shouldCalculate: Bool = false
        for value in Value.GroupType.testGroups {
            if let probability = value.probability {
                sum += probability
                shouldCalculate = true
            } else {
                if shouldCalculate {
                    appAssertionFailure("Sum should be zero")
                }
            }
        }
        if shouldCalculate {
            appAssert(abs(sum - 1) < 0.0001, "Sum should be equal to one")
        }
        return shouldCalculate
    }
}
