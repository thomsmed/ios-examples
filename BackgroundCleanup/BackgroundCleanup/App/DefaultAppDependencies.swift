//
//  DefaultAppDependencies.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 17/07/2022.
//

import UIKit

final class DefaultAppDependencies {

    let application: Application
    let itemRepository: ItemRepository
    let refreshService: RefreshService
    let cleanupService: CleanupService

    init() {
        application = UIApplication.shared
        itemRepository = DefaultItemRepository()
        refreshService = DefaultRefreshService(application: application, itemRepository: itemRepository)
        cleanupService = DefaultCleanupService(application: application, itemRepository: itemRepository)
    }
}

extension DefaultAppDependencies: AppDependencies {
    
}
