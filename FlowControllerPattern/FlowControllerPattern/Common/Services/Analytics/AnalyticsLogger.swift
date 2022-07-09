//
//  AnalyticsLogger.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 09/07/2022.
//

import Foundation

enum Analytics {
    enum Source: String {
        case exploreStoresMap
        case exploreStoresList
        case activityPurchasesActive
        case activityPurchasesHistory
        case profileHome
        case profileEdit
    }

    enum Event {
        case bookingComplete(source: Analytics.Source)
    }

    enum Property {
        case hasCompletedOnboarding(value: Bool?)
    }
}

protocol AnalyticsLogger: AnyObject {
    func log(_ event: Analytics.Event)
    func set(_ property: Analytics.Property)
}
