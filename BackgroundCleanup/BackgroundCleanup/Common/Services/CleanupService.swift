//
//  CleanupService.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 17/07/2022.
//

import Foundation
import BackgroundTasks

protocol CleanupService: AnyObject {
    func ensureScheduled()
}

final class DefaultCleanupService {

    // NOTE: Scheduling ProcessingTasks require your app to declare
    // Background Mode: Background Processing under its project's Signing and Capabilities tab.

    // NOTE: Processing task identifier must be defined in Info.plist (in a list under the BGTaskSchedulerPermittedIdentifiers key).
    private let processingTaskIdentifier = "com.thomsmed.processingTask"

    private let taskScheduler: BGTaskScheduler = .shared

    private let itemRepository: ItemRepository

    init(itemRepository: ItemRepository) {
        self.itemRepository = itemRepository
    }

    private func registerHandler() {
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

    private func scheduleProcessingTask() {
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
            task.setTaskCompleted(success: true)
        }
    }
}

extension DefaultCleanupService: CleanupService {

    func ensureScheduled() {
        //NOTE: Re-scheduling a background task will clear the previous schedule.

        registerHandler() // All handlers must be registered before application finishes launching

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
}
