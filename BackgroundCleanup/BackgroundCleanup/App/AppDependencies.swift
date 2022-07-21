//
//  AppDependencies.swift
//  BackgroundCleanup
//
//  Created by Thomas Asheim Smedmann on 17/07/2022.
//

import Foundation

protocol AppDependencies: AnyObject {
    var application: Application { get }
    var itemRepository: ItemRepository { get }
    var refreshService: RefreshService { get }
    var cleanupService: CleanupService { get }
}
