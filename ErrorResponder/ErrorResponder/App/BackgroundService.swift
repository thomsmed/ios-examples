//
//  BackgroundService.swift
//  ErrorResponder
//
//  Created by Thomas Asheim Smedmann on 07/10/2024.
//

import Foundation
import OSLog

extension Logger {
    static let general = Logger(subsystem: "ios.example.ErrorResponder.BackgroundService", category: "General")
}

enum BackgroundServiceError: Error, CaseIterable {
    case nonCritical
    case critical

    static var random: BackgroundServiceError {
        BackgroundServiceError.allCases[Int.random(in: 0..<Self.allCases.count)]
    }
}

final actor BackgroundService {
    private var errorResponderChain: ErrorResponderChain? = nil
    private var pollingTask: Task<Void, Never>? = nil

    private func restartPolling() {
        stop()

        Logger.general.info("Starting background work polling")

        pollingTask = Task {
            var n = 0

            while true {
                defer { n += 1 }

                do {
                    try await Task.sleep(for: .seconds(3))

                    // Do some service work in the background, report errors to the Error Responder chain.
                    if n % 2 != 0 {
                        throw BackgroundServiceError.random
                    } else {
                        Logger.general.info("Successfully did some background work")
                    }
                } catch {
                    switch await errorResponderChain?.respond(to: error) ?? .abort {
                        case .proceed:
                            Logger.general.info("Non critical error happened during work polling. Ignore, and proceed as normal.")
                        default:
                            Logger.general.info("Critical error happened during polling. Restarting work polling.")
                            return restartPolling()
                    }
                }
            }
        }
    }

    deinit {
        if pollingTask != nil {
            Logger.general.info("Stopping background work polling")
        }

        pollingTask?.cancel()
        pollingTask = nil
    }
}

extension BackgroundService {
    func start(andBindTo errorResponderChain: ErrorResponderChain) {
        self.errorResponderChain = errorResponderChain
        restartPolling()
    }

    func stop() {
        if pollingTask != nil {
            Logger.general.info("Stopping background work polling")
        }

        pollingTask?.cancel()
        pollingTask = nil
    }
}
