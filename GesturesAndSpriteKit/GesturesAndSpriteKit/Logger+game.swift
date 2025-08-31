//
//  Logger+game.swift
//  GesturesAndSpriteKit
//
//  Created by Thomas Smedmann on 31/08/2025.
//

import Foundation
import OSLog

extension Logger {

    static let game = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "Game")
}
