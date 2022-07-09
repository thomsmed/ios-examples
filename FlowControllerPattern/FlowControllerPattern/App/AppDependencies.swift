//
//  AppDependencies.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 04/07/2022.
//

import Foundation

protocol AppDependencies: AnyObject {
    var analytics: AnalyticsLogger { get }
    var crashlytics: CrashlyticsRecorder { get }
    var storeService: StoreService { get }
    var bookingService: BookingService { get }
}
