//
//  NetworkMonitor.swift
//  NetworkMonitoring
//
//  Created by Thomas Asheim Smedmann on 06/11/2022.
//

import Foundation
import Network
import Combine

final class NetworkMonitor {

    struct State {
        let description: String
        let availableInterfaces: [String]
    }

    let networkPathMonitor = NWPathMonitor() // Monitor all network interfaces by default

    @Published private(set) var state: State?

    func start() {
        networkPathMonitor.pathUpdateHandler = { path in
            self.state = .init(
                description: path.debugDescription,
                availableInterfaces: path.availableInterfaces.map { $0.debugDescription }
            )
        }

        networkPathMonitor.start(queue: .main)
    }

    func cancel() {
        networkPathMonitor.cancel()
    }
}
