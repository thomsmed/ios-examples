//
//  CleanupService.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 17/07/2022.
//

import UIKit
import BackgroundTasks

protocol CleanupService: AnyObject {
    func registerHandler()
    func forceCleanup()
    func ensureScheduled()
    func lastCleanup() -> Date?
}

final class DefaultCleanupService {

    // NOTE: Scheduling ProcessingTasks require your app to declare
    // Background Mode: Background Processing under its project's Signing and Capabilities tab.

    // NOTE: Processing task identifier must be defined in Info.plist (in a list under the BGTaskSchedulerPermittedIdentifiers key).
    private let processingTaskIdentifier = "com.thomsmed.processingTask"

    private let taskScheduler: BGTaskScheduler = .shared

    private let lastCleanupKey = "com.thomsmed.CleanupService.LastCleanup"

    private let userDefaults = UserDefaults.standard

    private let application: Application
    private let itemRepository: ItemRepository

    init(application: Application, itemRepository: ItemRepository) {
        self.application = application
        self.itemRepository = itemRepository
    }

    private func scheduleProcessingTask() {
        // NOTE: Submitting background task requests is blocking,
        // so be mindful of when and how you submit your background task requests.

        do {
            let request = BGProcessingTaskRequest(
                identifier: processingTaskIdentifier
            )
            if let thisEarlyMorningDate = Calendar.current.date(bySettingHour: 1, minute: 0, second: 0, of: .now) {
                request.earliestBeginDate = Calendar.current.date(byAdding: .day, value: 1, to: thisEarlyMorningDate)
            }
            request.requiresExternalPower = false
            request.requiresNetworkConnectivity = false
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

        // Delete items that are more than one day old
        guard
            let thisMorningDate = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: .now),
            let expirationDate = Calendar.current.date(byAdding: .day, value: -1, to: thisMorningDate)
        else {
            return task.setTaskCompleted(success: true)
        }

        itemRepository.deleteItems(olderThan: expirationDate) {
            self.store(lastCleanup: .now)
            task.setTaskCompleted(success: true)
        }
    }

    private func store(lastCleanup: Date) {
        userDefaults.set(lastCleanup.timeIntervalSince1970, forKey: lastCleanupKey)
    }
}

extension DefaultCleanupService: CleanupService {

    func registerHandler() {
        // NOTE: All handlers must be registered before application finishes launching

        guard BGTaskScheduler.shared.register(
            forTaskWithIdentifier: processingTaskIdentifier,
            using: nil,
            launchHandler: { backgroundTask in
                guard let processingTask = backgroundTask as? BGProcessingTask else {
                    return
                }

                self.handle(task: processingTask)
            }
        ) else {
            fatalError("Failed to register launch handler for Processing Task. Check that \(processingTaskIdentifier) is defined in Info.plist")
        }
    }

    func forceCleanup() {
        // NOTE: Force a refresh of your data when you can while the user is engaged with the app.
        // It is always recommended to do such work when the app is in the foreground.
        // You can never be 100% sure a background task will be run by the system (iOS).
        // Delete items that are more than one day old

        guard
            let thisMorningDate = Calendar.current.date(bySettingHour: 6, minute: 0, second: 0, of: .now),
            let expirationDate = Calendar.current.date(byAdding: .day, value: -1, to: thisMorningDate)
        else {
            return
        }

        var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
        backgroundTaskIdentifier = application.beginBackgroundTask {
            // The app is suspending our app, and stopping task execution
            self.application.endBackgroundTask(backgroundTaskIdentifier)
        }

        itemRepository.deleteItems(olderThan: expirationDate) {
            self.store(lastCleanup: .now)
            self.application.endBackgroundTask(backgroundTaskIdentifier)
        }
    }

    func ensureScheduled() {
        // NOTE: Re-scheduling a background task will clear the previous schedule.

        taskScheduler.getPendingTaskRequests { taskRequests in
            if taskRequests.contains(
                where: { taskRequest in taskRequest.identifier == self.processingTaskIdentifier }
            ) {
                return // Already scheduled
            }

            // Only schedule this background task when it is not already scheduled
            self.scheduleProcessingTask()
        }
    }

    func lastCleanup() -> Date? {
        let timeIntervalSince1970 = userDefaults.double(forKey: lastCleanupKey)

        guard timeIntervalSince1970 > 0 else {
            return nil
        }

        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }
}
