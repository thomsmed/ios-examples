//
//  CrashlyticsRecorder.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 09/07/2022.
//

import Foundation

enum Crashlytics {
    enum Level {
        case info
        case warning
        case fatal
    }
}

protocol CrashlyticsRecorder {
    func record(_ error: Error, level: Crashlytics.Level)
}
