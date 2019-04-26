//
//  Object+Singletone.swift
//  CHMeetupApp
//
//  Created by Alexander Zimin on 04/03/2017.
//  Copyright © 2017 CocoaHeads Community. All rights reserved.
//

import Foundation
import RealmSwift

public protocol ObjectSingletone: class {
    static var realmToWrite: Realm? { get }
    static func create() -> Self
}

extension ObjectSingletone {
    public static var realmToWrite: Realm? {
        return RealmController.shared.mainRealm
    }
}

extension ObjectSingletone where Self: Object {
  public static var value: Self {
    let object = self.realmToWrite?.objects(Self.self).first
    if let value = object {
      return value
    } else {
      let value = self.create()

      self.realmToWrite?.realmWrite {
        self.realmToWrite?.add(value)
      }

      return value
    }
  }
}
