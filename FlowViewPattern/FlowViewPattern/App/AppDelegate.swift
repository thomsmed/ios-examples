//
//  AppDelegate.swift
//  FlowViewPattern
//
//  Created by Thomas Asheim Smedmann on 07/08/2022.
//

import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {

    // NOTE: Let AppDelegate conform to ObservableObject if you need to have access to the delegate as an EnvironmentObject

    private(set) lazy var appDependencies: AppDependencies = DefaultAppDependencies()

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {

        // Do initial stuff, like register for remote notifications or initialising third party libraries etc

        application.registerForRemoteNotifications()

        return true
    }
}

// MARK: Remote notifications

extension AppDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError")
    }
}
