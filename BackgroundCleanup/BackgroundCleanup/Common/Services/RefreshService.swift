//
//  RefreshService.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 17/07/2022.
//

import Foundation
import BackgroundTasks

protocol RefreshService: AnyObject {
    func ensureScheduled()
}

final class DefaultRefreshService {

    // NOTE: Scheduling AppRefreshTasks require your app to declare
    // Background Mode: Background Refresh under its project's Signing and Capabilities tab.

    // NOTE: App refresh task identifier must be defined in Info.plist (in a list under the BGTaskSchedulerPermittedIdentifiers key).
    private let appRefreshTaskIdentifier = "com.thomsmed.appRefreshTask"

    private let taskScheduler: BGTaskScheduler = .shared

    private let itemRepository: ItemRepository

    init(itemRepository: ItemRepository) {
        self.itemRepository = itemRepository
    }

    private func registerHandler() {
        taskScheduler.register(
            forTaskWithIdentifier: appRefreshTaskIdentifier,
            using: nil
        ) { backgroundTask in
            guard let appRefreshTask = backgroundTask as? BGAppRefreshTask else {
                return
            }

            self.handle(task: appRefreshTask)
        }
    }

    private func scheduleAppRefreshTask() {
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
            task.setTaskCompleted(success: true)
        }
    }
}

extension DefaultRefreshService: RefreshService {

    func ensureScheduled() {
        //NOTE: Re-scheduling a background task will clear the previous schedule.

        registerHandler() // All handlers must be registered before application finishes launching
        scheduleAppRefreshTask()
    }
}
