//
//  DataSource.swift
//  Core
//
//  Created by Alexander Zimin on 23/09/2018.
//  Copyright © 2018 questsMaffia. All rights reserved.
//

import Foundation

public protocol TimeTravelDataSourceProtocol: class {
    var shouldReturnTimerDate: Bool { get }
    var timerEndDate: Date? { set get }
    var lastLoadedDate: Date? { set get }
}
