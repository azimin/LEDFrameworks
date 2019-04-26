//
//  SplitTest.swift
//  SplitTests
//
//  Created by Alex Zimin on 15/06/2018.
//  Copyright © 2018 Akexander. All rights reserved.
//

import Foundation

public protocol SplitTestProtocol {
  associatedtype GroupType: SplitTestGroupProtocol
  static var identifier: String { get }

  var currentGroup: GroupType { get }

  var analytics: ProductAnalyticsServiceProtocol { get }
  init(currentGroup: GroupType, analytics: ProductAnalyticsServiceProtocol)

  func hitSplitTest()
}

extension SplitTestProtocol {
  public func hitSplitTest() {
    analytics.setPersonPropertyOnce(name: Self.analyticsKey, value: self.currentGroup.rawValue as NSObject)
  }

  static var analyticsKey: String {
    return "split_test-\(self.identifier)"
  }

  static var dataBaseKey: String {
    return "split_test_database-\(self.identifier)"
  }
}
