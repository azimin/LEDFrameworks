//
//  Realm+WriteFunctions.swift
//  CHMeetupApp
//
//  Created by Alexander Zimin on 04/03/2017.
//  Copyright © 2017 CocoaHeads Community. All rights reserved.
//

import Foundation
import RealmSwift
import LEDCore

extension Realm {
  public func realmWrite(_ block: (() -> Void)) {
    if isInWriteTransaction {
      block()
    } else {
      do {
        try write(block)
      } catch {
        NotificationCenter.default.post(name: .RealmWritingErrorNotifications,
                                        object: nil)
        appAssertionFailure("Realm write error: \(error)")
      }
    }
  }
}

public func realmWrite(realm: Realm? = RealmController.shared.mainRealm, _ block: (() -> Void)) {
  realm?.realmWrite(block)
}
