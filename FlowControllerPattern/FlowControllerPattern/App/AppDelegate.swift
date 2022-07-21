//
//  AppDelegate.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    lazy var appDependencies = DefaultAppDependencies()
    lazy var appFlowFactory = DefaultAppFlowFactory(appDependencies: appDependencies)
    lazy var appFlowHost = DefaultAppFlowHost(flowFactory: appFlowFactory)

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        application.registerForRemoteNotifications()

        appFlowHost.applicationDidFinishLaunchingWith(launchOptions)

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: Remote notifications

extension AppDelegate {

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("didRegisterForRemoteNotificationsWithDeviceToken:", deviceToken)
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("didFailToRegisterForRemoteNotificationsWithError:", error)
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("didReceiveRemoteNotification:", userInfo)
        completionHandler(.noData)
    }
}
