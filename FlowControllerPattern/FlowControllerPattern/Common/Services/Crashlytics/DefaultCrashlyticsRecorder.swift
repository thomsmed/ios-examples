//
//  DefaultCrashlyticsRecorder.swift
//  FlowControllerPattern
//
//  Created by Thomas Asheim Smedmann on 09/07/2022.
//

import Foundation

final class DefaultCrashlyticsRecorder {

}

extension DefaultCrashlyticsRecorder: CrashlyticsRecorder {

    func record(_ error: Error, level: Crashlytics.Level) {
        
    }
}
