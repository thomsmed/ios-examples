//
//  AppDelegate.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 15/07/2022.
//

import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let appDependencies: AppDependencies = DefaultAppDependencies()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Pre iOS 13:
        application.setMinimumBackgroundFetchInterval(24 * 60 * 60) // Once a day

        // NOTE: All handlers for background tasks must be registered before application finishes launching.
        appDependencies.refreshService.registerHandler()
        appDependencies.cleanupService.registerHandler()

        BGTaskScheduler.shared.getPendingTaskRequests { taskRequests in
            print("Scheduled background tasks:")
            print(taskRequests)
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
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

extension AppDelegate {

    // Pre iOS 13:
    func application(
        _ application: UIApplication,
        performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        // Do some app refresh stuff...
    }
}
