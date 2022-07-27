//
//  DefaultAppDependencies.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import Foundation

final class DefaultAppDependencies {

    let analytics: AnalyticsLogger
    let crashlytics: CrashlyticsRecorder
    let storeService: StoreService
    let bookingService: BookingService

    init() {
        analytics = DefaultAnalyticsLogger()
        crashlytics = DefaultCrashlyticsRecorder()
        storeService = DefaultStoreService()
        bookingService = DefaultBookingService()
    }
}

extension DefaultAppDependencies: AppDependencies {
    
}
