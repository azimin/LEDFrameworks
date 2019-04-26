//
//  Core.swift
//  Core
//
//  Created by Alexander Zimin on 22/09/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation

public class Core {
    private static var isSet = false

    public static func setup(assertionHandler: AssertionHandler, timeTravelDataSource: TimeTravelDataSourceProtocol) {
        if self.isSet {
            appAssertionFailure("Core already set")
        } else {
            ServiceLocator.shared = ServiceLocator(assertionHandler: assertionHandler, timeTravelDataSource: timeTravelDataSource)
            self.isSet = true
        }

    }
}
