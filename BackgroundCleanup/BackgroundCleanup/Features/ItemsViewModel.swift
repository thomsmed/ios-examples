//
//  ItemsViewModel.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 17/07/2022.
//

import Foundation
import Combine
import UIKit

final class ItemsViewModel {

    enum Status {
        case idle
        case loading
        case ready
    }

    private let application: Application
    private let itemRepository: ItemRepository
    private let refreshService: RefreshService
    private let cleanupService: CleanupService

    private let statusSubject = CurrentValueSubject<Status, Never>(.idle)

    private(set) var items = [Item]()

    init(
        application: Application,
        itemRepository: ItemRepository,
        refreshService: RefreshService,
        cleanupService: CleanupService
    ) {
        self.application = application
        self.itemRepository = itemRepository
        self.refreshService = refreshService
        self.cleanupService = cleanupService
    }
}

extension ItemsViewModel {

    var status: AnyPublisher<Status, Never> {
        statusSubject.eraseToAnyPublisher()
    }

    func refreshItems() {
        statusSubject.send(.loading)

        itemRepository.listItems { [weak self] items in
            self?.items = items
            self?.statusSubject.send(.ready)
        }
    }

    func addItem() {
        // NOTE: Work queued on a Dispatch Queue right before entering background will be run after the app enter foreground again
        // (if the app did not get killed while in background).

        // Mark the next block as a background task, to try and guarantee a new item is successfully added.
        var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
        backgroundTaskIdentifier = application.beginBackgroundTask {
            // Background execution time exceeded.
            // Called by the system if your task did not manage to call UIApplication.endBackgroundTask(_:) in time.
            // NOTE: The app process normally get up to around 30 sec extra execution time when using this api to finish tasks in the background.

            self.statusSubject.send(.idle)

            self.application.endBackgroundTask(backgroundTaskIdentifier)
        }

        statusSubject.send(.loading)

        itemRepository.generateNewItem { item in
            self.items.append(item)

            self.statusSubject.send(.ready)

            self.application.endBackgroundTask(backgroundTaskIdentifier)
        }
    }

    func lastRefresh() -> String {
        guard let lastRefresh = refreshService.lastRefresh() else {
            return "Last refresh: Never"
        }

        return "Last refresh: \(lastRefresh.formatted())"
    }

    func lastCleanup() -> String {
        guard let lastCleanup = cleanupService.lastCleanup() else {
            return "Last cleanup: Never"
        }

        return "Last cleanup: \(lastCleanup.formatted())"
    }
}
