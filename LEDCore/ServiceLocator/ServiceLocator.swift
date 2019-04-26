//
//  ServiceLocator.swift
//  Core
//
//  Created by Alexander Zimin on 22/09/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation

public class ServiceLocator {
    internal(set) public static var shared: ServiceLocator!

    let assertionHandler: AssertionHandler
    let timeTravelDataSource: TimeTravelDataSourceProtocol

    internal init(assertionHandler: AssertionHandler, timeTravelDataSource: TimeTravelDataSourceProtocol) {
        self.assertionHandler = assertionHandler
        self.timeTravelDataSource = timeTravelDataSource
    }
}
