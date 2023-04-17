//
//  AppDelegate.swift
//  breadwallet
//
//  Created by Aaron Voisine on 10/5/16.
//  Copyright (c) 2016-2019 Breadwinner AG. All rights reserved.
//

import UIKit
import LocalAuthentication

class AppDelegate: UIResponder, UIApplicationDelegate {

    private var window: UIWindow? {
        return applicationController.window
    }
    let applicationController = ApplicationController()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        redirectStdOut()
        
        UIView.swizzleSetFrame()
        applicationController.launch(application: application, options: launchOptions)
        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        applicationController.didBecomeActive()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        applicationController.willEnterForeground()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        applicationController.didEnterBackground()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        applicationController.willResignActive()
    }
    
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplication.ExtensionPointIdentifier) -> Bool {
        return false // disable extensions such as custom keyboards for security purposes
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        applicationController.application(application, didFailToRegisterForRemoteNotificationsWithError: error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        applicationController.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return applicationController.open(url: url)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let webpageURL = userActivity.webpageURL else { return false }
        
        DynamicLinksManager.handleDynamicLink(dynamicLink: webpageURL)
        
        // The Plaid Link SDK ignores unexpected URLs passed to `resumeAfterTermination(from:)` as
        // per Apple’s recommendations, so there is no need to filter out unrelated URLs.
        // Doing so may prevent a valid URL from being passed to `resumeAfterTermination(from:)` and OAuth may not continue as expected.
        guard let linkOAuthHandler = window?.rootViewController as? LinkOAuthHandling,
              let handler = linkOAuthHandler.plaidHandler else { return false }
        // Continue the Link flow
        handler.resumeAfterTermination(from: webpageURL)
        
        return true
    }

    // stdout is redirected to Constant.logFilePath for testflight and debug builds
    private func redirectStdOut() {
        guard E.isDebug || E.isTestFlight else { return }
        
        let logFilePath = Constant.logFilePath
        let previousLogFilePath = Constant.previousLogFilePath
        
        // If there is already content at Constant.logFilePath from the previous run of the app,
        // store that content in Constant.previousLogFilePath so that we can upload both the previous
        // and current log from Menu / Developer / Send Logs.
        if FileManager.default.fileExists(atPath: logFilePath.path),
           let logData = try? Data(contentsOf: logFilePath) {
            // save the logging data from the previous run of the app
            try? logData.write(to: previousLogFilePath, options: Data.WritingOptions.atomic)
        }
        
        logFilePath.withUnsafeFileSystemRepresentation {
            _ = freopen($0, "w+", stdout)
        }
    }
}
