//
//  AnalyticsService.swift
//  LEDAnalytics
//
//  Created by Alexander Zimin on 26/04/2019.
//  Copyright © 2019 led. All rights reserved.
//

import Foundation
import FacebookCore
import FBSDKCoreKit

public class AnalyticsApplicationEventsHandler {
    private(set) public static var shared: AnalyticsApplicationEventsHandler = AnalyticsApplicationEventsHandler()

    public func activateApp() {
        FBSDKAppEvents.activateApp()
    }

    public typealias DeferredAppLinkHandler = (_ url: URL?, _ error: Error?) -> Void
    public func fetchDeferredFacebookAppLink(_ handler: @escaping DeferredAppLinkHandler) {
        FBSDKAppLinkUtility.fetchDeferredAppLink(handler)
    }

    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    public func logFacebookNotificationOpen(userInfo: [AnyHashable : Any]) {
        FBSDKAppEvents.logPushNotificationOpen(userInfo)
    }

    public func setFacebookPushNotifications(deviceToken: Data) {
        FBSDKAppEvents.setPushNotificationsDeviceToken(deviceToken)
    }
}
