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

    enum BackgroundTaskIdentifier: String {
        // App refresh task defined in Info.plist
        case appRefreshTask = "com.thomsmed.appRefreshTask"
        // App processing task defined in Info.plist
        case processingTask = "com.thomsmed.processingTask"
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // Pre iOS 13:
        application.setMinimumBackgroundFetchInterval(24 * 60 * 60) // Once a day

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskIdentifier.appRefreshTask.rawValue,
            using: nil
        ) { backgroundTask in
            guard let appRefreshTask = backgroundTask as? BGAppRefreshTask else {
                return
            }

            self.handle(task: appRefreshTask)
        }

        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskIdentifier.processingTask.rawValue,
            using: nil
        ) { backgroundTask in
            guard let processingTask = backgroundTask as? BGProcessingTask else {
                return
            }

            self.handle(task: processingTask)
        }

        // Initial scheduling of background tasks
        scheduleAppRefreshTask()
        scheduleProcessingTask()

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

// MARK: Handeling App Refresh Task

extension AppDelegate {

    private func scheduleAppRefreshTask() {
        do {
            let request = BGAppRefreshTaskRequest(
                identifier: BackgroundTaskIdentifier.appRefreshTask.rawValue
            )
            request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule App refresh task, with error:", error)
        }
    }

    private func handle(task: BGAppRefreshTask) {
        scheduleAppRefreshTask()

        task.expirationHandler = {
            // Clean up non completed tasks
            task.setTaskCompleted(success: false)
        }
        
        guard let data = UserDefaults.standard.data(forKey: "data") else {
            return task.setTaskCompleted(success: true)
        }

        let jsonDecoder = JSONDecoder()
        var dataArray = (try? jsonDecoder.decode([SomeData].self, from: data)) ?? []

        // Add fresh data
        dataArray.append(.init(content: "Data item \(dataArray.count)", timestamp: .now))

        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(dataArray) else {
            return task.setTaskCompleted(success: true)
        }

        UserDefaults.standard.set(data, forKey: "data")

        task.setTaskCompleted(success: true)
    }
}

// MARK: Handeling Processing Task

extension AppDelegate {

    private func scheduleProcessingTask() {
        do {
            let request = BGAppRefreshTaskRequest(
                identifier: BackgroundTaskIdentifier.processingTask.rawValue
            )
            request.earliestBeginDate = Calendar.current.date(byAdding: .day, value: 1, to: .now)
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule Processing task, with error:", error)
        }
    }

    private func handle(task: BGProcessingTask) {
        scheduleProcessingTask()

        task.expirationHandler = {
            // Clean up non completed tasks
            task.setTaskCompleted(success: false)
        }

        guard let data = UserDefaults.standard.data(forKey: "data") else {
            return task.setTaskCompleted(success: true)
        }

        let jsonDecoder = JSONDecoder()
        var dataArray = (try? jsonDecoder.decode([SomeData].self, from: data)) ?? []

        // Delete old data
        dataArray.removeAll(where: { someData in
            guard let expirationDate = Calendar.current.date(byAdding: .day, value: 1, to: someData.timestamp) else {
                return false
            }

            return Date.now > expirationDate
        })

        let jsonEncoder = JSONEncoder()
        guard let data = try? jsonEncoder.encode(dataArray) else {
            return task.setTaskCompleted(success: true)
        }

        UserDefaults.standard.set(data, forKey: "data")

        task.setTaskCompleted(success: true)
    }
}
