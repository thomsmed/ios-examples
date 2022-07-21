//
//  RefreshService.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 17/07/2022.
//

import UIKit
import BackgroundTasks

protocol RefreshService: AnyObject {
    func registerHandler()
    func forceRefresh()
    func ensureScheduled()
    func lastRefresh() -> Date?
}

final class DefaultRefreshService {

    // NOTE: Scheduling AppRefreshTasks require your app to declare
    // Background Mode: Background Refresh under its project's Signing and Capabilities tab.

    // NOTE: App refresh task identifier must be defined in Info.plist (in a list under the BGTaskSchedulerPermittedIdentifiers key).
    private let appRefreshTaskIdentifier = "com.thomsmed.appRefreshTask"

    private let taskScheduler: BGTaskScheduler = .shared

    private let lastRefreshKey = "com.thomsmed.RefreshService.LastRefresh"

    private let userDefaults = UserDefaults.standard

    private let application: Application
    private let itemRepository: ItemRepository

    init(application: Application, itemRepository: ItemRepository) {
        self.application = application
        self.itemRepository = itemRepository
    }

    private func scheduleAppRefreshTask() {
        // NOTE: Submitting background task requests is blocking,
        // so be mindful of when and how you submit your background task requests.

        do {
            let request = BGAppRefreshTaskRequest(
                identifier: appRefreshTaskIdentifier
            )
            request.earliestBeginDate = Calendar.current.date(byAdding: .hour, value: 1, to: .now)
            try taskScheduler.submit(request)
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

        itemRepository.generateNewItem { _ in
            self.store(lastRefresh: .now)
            task.setTaskCompleted(success: true)
        }
    }

    private func store(lastRefresh: Date) {
        userDefaults.set(lastRefresh.timeIntervalSince1970, forKey: lastRefreshKey)
    }
}

extension DefaultRefreshService: RefreshService {

    func registerHandler() {
        // NOTE: All handlers must be registered before application finishes launching

        guard taskScheduler.register(
            forTaskWithIdentifier: appRefreshTaskIdentifier,
            using: nil,
            launchHandler: { backgroundTask in
                guard let appRefreshTask = backgroundTask as? BGAppRefreshTask else {
                    return
                }

                self.handle(task: appRefreshTask)
            }
        ) else {
            fatalError("Failed to register launch handler for App Refresh Task. Check that \(appRefreshTaskIdentifier) is defined in Info.plist")
        }
    }

    func forceRefresh() {
        // NOTE: Force a refresh of your data when you can while the user is engaged with the app.
        // It is always recommended to do such work when the app is in the foreground.
        // You can never be 100% sure a background task will be run by the system (iOS).

        var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
        backgroundTaskIdentifier = application.beginBackgroundTask {
            // The app is suspending our app, and stopping task execution
            self.application.endBackgroundTask(backgroundTaskIdentifier)
        }

        itemRepository.generateNewItem { _ in
            self.store(lastRefresh: .now)
            self.application.endBackgroundTask(backgroundTaskIdentifier)
        }
    }

    func ensureScheduled() {
        // NOTE: Re-scheduling a background task will clear the previous schedule.

        scheduleAppRefreshTask()
    }

    func lastRefresh() -> Date? {
        let timeIntervalSince1970 = userDefaults.double(forKey: lastRefreshKey)

        guard timeIntervalSince1970 > 0 else {
            return nil
        }

        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }
}
