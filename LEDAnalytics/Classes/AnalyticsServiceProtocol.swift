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
        AppEvents.activateApp()
    }

    public typealias DeferredAppLinkHandler = (_ url: URL?, _ error: Error?) -> Void
    public func fetchDeferredFacebookAppLink(_ handler: @escaping DeferredAppLinkHandler) {
        AppLinkUtility.fetchDeferredAppLink(handler)
    }

    public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return ApplicationDelegate.shared.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    public func logFacebookNotificationOpen(userInfo: [AnyHashable : Any]) {
        AppEvents.logPushNotificationOpen(userInfo)
    }

    public func setFacebookPushNotifications(deviceToken: Data) {
        AppEvents.setPushNotificationsDeviceToken(deviceToken)
    }
}
