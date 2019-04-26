//
//  Realm+Notifications.swift
//  CHMeetupApp
//
//  Created by Alexander Zimin on 04/03/2017.
//  Copyright © 2017 CocoaHeads Community. All rights reserved.
//

import Foundation

extension Notification.Name {
  public static let RealmLoadingErrorNotifications: Notification.Name =
    Notification.Name(rawValue: "RealmLoadingErrorNotifications")
  public static let RealmWritingErrorNotifications: Notification.Name =
    Notification.Name(rawValue: "RealmWritingErrorNotifications")
}
