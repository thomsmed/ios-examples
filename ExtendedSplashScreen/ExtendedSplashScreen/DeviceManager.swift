//
//  DeviceManager.swift
//  ExtendedSplashScreen
//
//  Created by Thomas Asheim Smedmann on 19/04/2023.
//

import Foundation

enum DeviceCheckResult {
    case ok
    case blocked
}

final actor DeviceManager {
    func checkDevice() async -> DeviceCheckResult {
        // Simulate some async device check to decide if the app is blocked or not.

        assert(!Thread.isMainThread) // Should always be true (only the main actor run stuff on main thread).

        try? await Task.sleep(for: .seconds(3))

        if Int.random(in: 0..<2) > 0 {
            return .ok
        } else {
            return .blocked
        }
    }
}
